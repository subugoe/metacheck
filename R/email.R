#' Render email
#' @param dois Character vector of DOIs
#' @param session_id Character vector to identify current shiny session
#' @family communicate
#' @export
render_email <- function(dois, session_id = NULL) {
  cr <- get_cr_md(dois)
  my_df <- cr_compliance_overview(cr)
  email <- blastula::compose_email(
    header = "metacheck: Open Access Metadata Compliance Checker",
    body = blastula::render_email(
      input = system.file(
        "rmarkdown/templates/email/reply_success_de/reply_success_de.Rmd",
        package = "metacheck"
      ),
      render_options = list(
        params = list(
          dois = dois,
          cr_overview = my_df,
          session_id = session_id
        )
      )
    )$html_html,
    footer = blastula::md(c(
      "Email sent on ", format(Sys.time(), "%a %b %d %X %Y"), "."
    ))
  )
  email <- add_attachment_xlsx(email, session_id = session_id)
  email
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
    shiny::textInput(
      inputId = ns("recipient"),
      label = "Email Address:",
      placeholder = "jane.doe@example.com",
      width = width
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
emailReportServer <- function(id, dois, email = blastula::prepare_test_message()) {
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
        shinyjs::toggleState("send", iv$is_valid() && shiny::isTruthy(dois()))
      })
      observeEvent(input$send, {
        if (iv$is_valid()) {
          withProgress(
            expr = {
              smtp_send_metacheck(
                to = input$recipient,
                email = email
              )
            },
            message = paste0(
              "Sending e-mail. ",
              "You can close this window."
            )
          )
        }
      })
    }
  )
}

#' Make Spreadsheet attachment
#'
#' @param .md list, returned from [cr_compliance_overview()]
#' @param dois character, submitted dois
#' @param session_id link spreadsheet to R session
#'
#' @importFrom writexl write_xlsx
#' @export
md_data_attachment <- function(.md = NULL, session_id = NULL, dois = NULL) {
  if (is.null(.md)) {
    stop("No Crossref Data")
  }
  excel_spreadsheet <- list(
    `Uebersicht` = .md$cr_overview,
    `CC-Lizenzen` = .md$cc_license_check
  )
  if (!is.null(.md$cr_tdm)) {
    excel_spreadsheet[["TDM"]] <- .md$tdm
  }
  if (!is.null(.md$cr_funder)) {
    excel_spreadsheet[["F\U00F6oerderinformationen"]] <- .md$funder_info
  }
  if (!length(tolower(dois) %in% tolower(.md$cr_overview$doi)) > 0)
    excel_spreadsheet[["Nicht-indexierte DOIs"]] <- tibble::tibble(
      mutate(missing_dois = !tolower(dois) %in% tolower(.md$cr_overview$doi))
    )
  # write_out
  writexl::write_xlsx(x = excel_spreadsheet,
                      path = xlsx_path(session_id))
}

#' Temp path to write xlsx to
#' @inheritParams render_email
#' @noRd
xlsx_path <- function(session_id = NULL) {
  fs::path_temp(paste0(session_id, "-license_df.xlsx"))
}
