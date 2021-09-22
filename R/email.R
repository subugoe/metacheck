#' Send metacheck results as an parametrised email
#' @family communicate
#' @name email
NULL

#' @describeIn email Compose complete mail
#' @inheritDotParams mc_render_email
#' @export
mc_compose_email <- function(translator = mc_translator(), ...) {
  mc_render_email(translator = translator, ...)$html_html %>%
    mc_compose_email_outer(translator = translator)
}

#' @describeIn email Wrap inner email in outer content
#' @inheritParams blastula::compose_email
#' @inheritParams mcControlsServer
#' @export
mc_compose_email_outer <- function(body = "Lorem",
                                   translator = mc_translator()) {
  biblids::stopifnot_i18n(translator)
  blastula::compose_email(
    header = blastula::blocks(
      title = blastula::block_title(translator$translate("Metacheck Results")),
      results = block_text_centered(translator$translate(
        "Here are your open access metadata compliance test results."
      )),
      disclaimer = block_text_centered_vec(
        translator$translate(
          # TODO https://github.com/subugoe/metacheck/issues/282
          # line breaking this breaks the translation
          # but should live in long docs anyway 
          "Metacheck supports your workflows to check OA metadata deposited by publishers, but it cannot conclusively check funding eligibility of OA publications."
        ),
        translator$translate(
          "Please consult the funding conditions of the respective funder."
        )
      )
    ),
    body = body,
    footer = blastula::blocks(
      support = block_text_centered_vec(
        translator$translate("Need help interpreting your results?"),
        blastula::add_cta_button(
          url = "http://subugoe.github.io/metacheck/articles/help.html",
          text = translator$translate("Get additional support")
        ),
        blastula::block_spacer()
      ),
      # newsletter is only available in german
      if (translator$get_translation_language() == "de") {
        list(
          newsletter = block_text_centered_vec(
            translator$translate("Stay tuned for new metacheck features."),
            blastula::add_cta_button(
              url = "http://subugoe.github.io/hoad/newsletter.html",
              text = translator$translate("Subscribe to our newsletter")
            )
          ),
          blastula::block_spacer()
        )
      },
      links = blastula::block_social_links(
        mc_social_link("website", "http://subugoe.github.io/metacheck"),
        mc_social_link(
          "email",
          "mailto:metacheck-support@sub.uni-goettingen.de"
        ),
        mc_social_link("GitHub", "http://github.com/subugoe/metacheck"),
        mc_social_link("Twitter", "https://twitter.com/subugoe")
      ),
      blastula::block_spacer(),
      copyright = block_text_centered_vec(
        blastula::add_image(
          file = "http://subugoe.github.io/metacheck/reference/figures/SUB_centered_cmyk.png",
          align = "center",
          alt = "SUB Logo",
          width = "200"
        )
      ),
      funding = block_text_centered_vec(
        blastula::add_image(
          file = "http://subugoe.github.io/metacheck/reference/figures/dfg_logo_schriftzug_blau_foerderung_en.jpg",
          align = "center",
          alt = "DFG logo",
          width = "200"
        )
      ),
      data = block_text_centered_vec(
        blastula::add_image(
          file = "http://subugoe.github.io/metacheck/reference/figures/crossref-metadata-apis-200@2x.png",
          align = "center",
          alt = "Crossref Member Badge",
          width = "200"
        )
      )
    ),
    title = "metacheck results"
  )
  # TODO enable https://github.com/subugoe/metacheck/issues/276
  # email <- add_attachment_xlsx(email, session_id = session_id)
}

#' Defaults for social links
#' @noRd
mc_social_link <- purrr::partial(blastula::social_link, variant = "dark_gray")

#' Centered block text
#' @noRd
block_text_centered <- purrr::partial(blastula::block_text, align = "center")

#' Vectorised helper
#' @noRd
block_text_centered_vec <- function(...) {
  block_text_centered(blastula::md(paste(..., collapse = " ")))
}

#' @describeIn email Render email body (inner content)
#' @inheritParams report
#' @param session_id Character vector to identify current shiny session
#' @inheritDotParams blastula::render_email
#' @export
mc_render_email <- function(dois = doi_examples$good[1:10],
                            translator = mc_translator(),
                            session_id = NULL,
                            ...) {
  # suppression is dangerous hack-fix for
  # https://github.com/subugoe/metacheck/issues/138
  # otherwise, tests are illegibly noisy
  suppressWarnings(
    blastula::render_email(
      input = path_report_rmd(lang = translator$get_translation_language()),
      render_options = list(
        params = list(
          dois = dois,
          session_id = session_id,
          translator = translator
        )
      ),
      ...
    )
  )
}

#' @describeIn email Render and send
#' @inheritDotParams mc_compose_email
#' @inheritParams smtp_send_mc
#' @export
render_and_send <- function(to, translator = mc_translator(), ...) {
  email <- mc_compose_email(
    # used to disambiguate excel file names, see #83
    session_id = as.character(floor(runif(1) * 1e20)),
    translator = translator,
    ...
  )
  smtp_send_mc(to = to, email = email, translator = translator)
}

#' @describeIn email Render and send asynchronously
#' @export
render_and_send_async <- function(...) {
  promises::future_promise(
    render_and_send(...),
    seed = TRUE
  )
  NULL
}

#' Add attachment to email
#' @inheritParams mc_render_email
#' @noRd
add_attachment_xlsx <- function(email, session_id = NULL) {
  blastula::add_attachment(
    email = email,
    file = xlsx_path(session_id),
    filename = "metadata_report.xlsx"
  )
}

#' Temp path to write xlsx to
#' @inheritParams mc_render_email
#' @keywords internal
xlsx_path <- function(session_id = NULL) {
  fs::path_temp(paste0(session_id, "-license_df.xlsx"))
}

# sending ====

#' @describeIn email Send
#' @inheritParams blastula::smtp_send
#' @inheritDotParams blastula::smtp_send
#' @export
smtp_send_mc <- function(email = blastula::prepare_test_message(),
                         to = throwaway,
                         from = "metacheck-support@sub.uni-goettingen.de",
                         credentials = creds_metacheck(),
                         translator = mc_translator(),
                         ...) {
  blastula::smtp_send(
    email = email,
    to = to,
    from = from,
    subject = mc_translator()$translate(
      "Metacheck: Your OA Metadata Compliance Check Results"
    ),
    if (is_prod()) cc = from,
    credentials = credentials,
    ...
  )
  invisible(email) # best practice
}

#' Get credentials for smtp
#' @noRd
creds_metacheck <- function() {
  auth_mailjet()
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
    user = mailjet_username,
    pass_envvar = "MAILJET_SMTP_PASSWORD",
    host = mailjet_smtp_server,
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
  server <- function(input, output, session) emailReportServer(id = "test")
  shiny::shinyApp(ui, server)
}

#' @describeIn emailReport Module UI
#' @inheritParams shiny::NS
#' @inheritParams shiny::textInput
#' @inheritParams biblids::doiEntryUI
#' @inheritDotParams shiny::actionButton
#' @export
emailReportUI <- function(id, width = "100%", translator = mc_translator(), ...) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shinyjs::useShinyjs(rmd = TRUE),
    shiny.i18n::usei18n(translator),
    shiny::textInput(
      inputId = ns("recipient"),
      label = translator$t("Email Address"),
      placeholder = "jane.doe@example.com",
      width = width
    ),
    shiny::p(
      translator$t("Emails are sent via the Mailjet SMTP relay service.")
    ),
    shiny::checkboxInput(
      ns("gdpr_consent"),
      label = shiny::tagList(shiny::p(
        translator$t("Let Mailjet GmbH process my email address."),
        shiny::a(
          href = "https://www.mailjet.de/dsgvo/",
          translator$t("Learn more.")
        )
      )),
      width = width
    ),
    shinyjs::disabled(
      shiny::actionButton(
        label = translator$t("Send Compliance Report"),
        inputId = ns("send"),
        icon = shiny::icon("paper-plane"),
        width = width,
        ...
      )
    )
  )
}

#' @describeIn emailReport Module server
#' @inheritParams biblids::doiEntryServer
#' @export
emailReportServer <- function(id,
                              dois = shiny::reactive(NULL),
                              translator = mc_translator(),
                              lang = shiny::reactive("en")) {
  stopifnot(shiny::is.reactive(dois))
  biblids::stopifnot_i18n(translator)
  stopifnot(shiny::is.reactive(lang))
  translWithLang <- shiny::reactive({
    translator$set_translation_language(lang())
    translator
  })
  shiny::moduleServer(
    id,
    module = function(input, output, session) {
      # update language client side
      shiny::observe(shiny.i18n::update_lang(session, lang()))
      # update language server side
      shiny::observe({
        shiny::updateTextAreaInput(
          session = session,
          inputId = "recipient",
          placeholder = translWithLang()$translate("jane.doe@example.com")
        )
      })

      # input validation
      iv <- shinyvalidate::InputValidator$new()
      iv$add_rule(
        "gdpr_consent",
        shinyvalidate::sv_equal(TRUE, "")
      )
      # translate msg
      shiny::observe({
        iv$add_rule(
          "recipient",
          shinyvalidate::sv_required(translWithLang()$translate("Required"))
        )
        iv$add_rule(
          "recipient",
          ~ if (!is_valid_email(.)) {
            translWithLang()$translate(
              "Please provide a valid email."
            )
          }
        )
      })
      
      # wait until email is typed before complaining
      shiny::observeEvent(input$recipient, iv$enable(), ignoreInit = TRUE)
      shiny::observe({
        shinyjs::toggleState("send", iv$is_valid() && !is.null(dois()))
      })
      shiny::observeEvent(input$send, {
        if (iv$is_valid()) {
          shiny::showModal(modalDialog(
            title = translWithLang()$translate(
              "You have successfully sent your DOIs"
            ),
            glue::glue(
              translWithLang()$translate(
                "You will receive an email with your report within the next 45 minutes. "
              ),
              translWithLang()$translate(
                "Please check your SPAM folder. "
              )
            ),
            easyClose = TRUE,
            footer = NULL
          ))
          render_and_send_async(
            to = input$recipient,
            dois = dois(),
            translator = translWithLang()
          )
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
#' @keywords internal
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
#' @inheritParams mc_render_email
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
