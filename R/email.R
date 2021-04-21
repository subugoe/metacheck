#' Render email
#' @param dois Character vector of DOIs
#' @param session_id Character vector to identify current shiny session
#' @inheritParams report
#' @family communicate
#' @export
render_email <- function(dois, lang = "en", session_id = NULL) {
  dois_ok <- dois[is_metacheckable(dois)]
  if (length(dois_ok) < 2) {
    rlang::abort("Too few eligible DOIs remaining.")
  }
  cr <- get_cr_md(dois_ok)
  my_df <- cr_compliance_overview(cr)
  email <- blastula::compose_email(
    header = "metacheck: Open Access Metadata Compliance Checker",
    # suppression is dangerous hack-fix for
    # https://github.com/subugoe/metacheck/issues/138
    # otherwise, tests are illegibly noisy
    body = suppressWarnings(
      blastula::render_email(
        input = path_report_rmd(lang),
        render_options = list(
          params = list(
            dois = dois,
            session_id = session_id
          )
        )
      )$html_html
    ),
    footer = blastula::md(c(
      "Email sent on ", format(Sys.time(), "%a %b %d %X %Y"), "."
    ))
  )
  # TODO enable again when xls is fine
  # email <- add_attachment_xlsx(email, session_id = session_id)
  email
}

#' @describeIn render_email Render and send
#' @inheritParams smtp_send_metacheck
render_and_send <- function(dois, to) {
  email <- render_email(
    dois,
    # used to disambiguate excel file names, see #83
    session_id = as.character(floor(runif(1) * 1e20))
  )
  smtp_send_metacheck(to = to, email)
}

#' @describeIn render_email Render and send asynchronously
#' @export
render_and_send_async <- function(dois, to) {
  promises::future_promise(render_and_send(dois = dois, to = to))
  NULL
}

#' Add attachment to email
#' @inheritParams render_email
#' @noRd
add_attachment_xlsx <- function(email, session_id = NULL) {
  blastula::add_attachment(
    email = email,
    file = xlsx_path(session_id),
    filename = "metadata_report.xlsx"
  )
}


#' Temp path to write xlsx to
#' @inheritParams render_email
xlsx_path <- function(session_id = NULL) {
  fs::path_temp(paste0(session_id, "-license_df.xlsx"))
}

# sending ====

#' Send out email
#' @inheritParams blastula::smtp_send
#' @inheritDotParams blastula::smtp_send
#' @family communicate
#' @keywords internal
#' @export
smtp_send_metacheck <- function(email,
                                to,
                                from = "metacheck-support@sub.uni-goettingen.de",
                                subject = "OA-Metadaten-Schnelltest: Ihr Ergebnis",
                                cc = from,
                                credentials = creds_metacheck(),
                                verbose = FALSE) {
  blastula::smtp_send(
    email = email,
    to = to,
    from = from,
    subject = subject,
    cc = cc,
    credentials = credentials,
    verbose = verbose
  )
  invisible(email)  # best practice
}

#' Get credentials for smtp
#' @noRd
creds_metacheck <- function() {
  if (has_creds_envvar()) {
    res <- creds_envvar_metacheck()
  } else {
    rlang::abort("No SMTP credentials found.")
  }
  res
}

#' Supply SMTP secret from env var
#' @noRd
creds_envvar_metacheck <- function() {
  blastula::creds_envvar(
    user = "7dd3848a47e310558c101fefb4d8edc5",
    pass_envvar = "MAILJET_SMTP_PASSWORD",
    host = "in-v3.mailjet.com",
    port = 587,
    use_ssl = TRUE
  )
}

has_creds_envvar <- function() Sys.getenv("MAILJET_SMTP_PASSWORD") != ""

skip_if_not_smtp_auth <- function() {
  ifelse(has_creds_envvar(), invisible(TRUE), skip("No SMTP auth available."))
}


# Email module ====

#' Email Report through a Shiny Module
#' @family communicate
#' @keywords internal
#' @name emailReport
NULL

#' @describeIn emailReport Test app
#' @export
emailReport <- function() {
  ui <- shiny::fluidPage(emailReportUI(id = "test"))
  server <- function(input, output, session) {
    emailReportServer(id = "test")
  }
  shiny::shinyApp(ui, server)
}

#' @describeIn emailReport Module UI
#' @inheritParams shiny::NS
#' @inheritParams shiny::textInput
#' @inheritDotParams shiny::actionButton
#' @export
emailReportUI <- function(id, width = "100%", ...) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shinyjs::useShinyjs(rmd = TRUE),
    shiny::textInput(
      inputId = ns("recipient"),
      label = "Email Address:",
      placeholder = "jane.doe@example.com",
      width = width
    ),
    shiny::p(
      "Emails are sent via the Mailjet SMTP relay service."
    ),
    shinyjs::disabled(
      shiny::actionButton(
        label = "Send Compliance Report",
        inputId = ns("send"),
        icon = shiny::icon("paper-plane"),
        width = width,
        ...
      )
    )
  )
}

#' @describeIn emailReport Module server
#' @export
emailReportServer <- function(id, dois) {
  shiny::moduleServer(
    id,
    module = function(input, output, session) {
      # input validation
      iv <- shinyvalidate::InputValidator$new()
      iv$add_rule("recipient", shinyvalidate::sv_required())
      iv$add_rule(
        "recipient",
        ~ if (!is_valid_email(.)) "Please provide a valid email"
      )
      iv$enable()
      observe({
        shinyjs::toggleState("send", iv$is_valid() && !is.null(dois))
      })
      observeEvent(input$send, {
        if (iv$is_valid()) {
          showModal(modalDialog(
            title = "You have succesfully send your DOIs",
            glue::glue(
              "An automated report will be send to your email ",
              "within the next 45 minutes. ",
              "Please check your SPAM folder. ",
              "If your have not received your email after an hour, ",
              "please contact us."
            ),
            easyClose = TRUE,
            footer = NULL
          ))
          render_and_send_async(to = input$recipient, dois = dois)
        }
      })
    }
  )
}

#' Make Spreadsheet attachment
#'
#' @param my_df compliance data from [cr_compliance_overview()]
#' @param dois character, submitted dois
#' @param session_id link spreadsheet to R session
#'
#' @importFrom writexl write_xlsx
#' @export
md_data_attachment <-
  function(my_df = NULL,
           dois = NULL,
           session_id = NULL) {
    is_compliance_overview_list(my_df)
    my_df[["pretest"]] <- tibble::tibble(
      # writexl does not know vctrs records
      doi = as.character(biblids::as_doi(dois)),
      tabulate_metacheckable(dois)
    )

    # write_out
    writexl::write_xlsx(x = my_df,
                        path = xlsx_path(session_id))
  }

#' Temp path to write xlsx to
#' @inheritParams render_email
#' @noRd
xlsx_path <- function(session_id = NULL) {
  fs::path_temp(paste0(session_id, "-license_df.xlsx"))
}

#' Data is available
#' @noRd
is_compliance_overview_list <- function(x) {
  assertthat::assert_that(x %has_name% c("cr_overview", "cc_license_check"),
                          msg = "No Compliance Data to attach, compliance data from [cr_compliance_overview()]"
  )}
