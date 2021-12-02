#' Send metacheck results as an parametrised email
#' @family communicate
#' @name email
NULL

#' @describeIn email Compose complete mail
#' @inheritDotParams mc_render_email
#' @inheritParams biblids::doiEntryUI
#' @export
mc_compose_email <- function(dois,
                             translator = mc_translator(),
                             ...) {
  mc_body_block(dois = dois, translator = translator, ...) %>%
    mc_compose_email_outer(translator = translator) %>%
    blastula::add_attachment(
      md_data_attachment(dois = dois),
      filename = translator$translate("mc_individual_results.xlsx")
    )
}

mc_body_block <- function(dois, translator = mc_translator(), ...) {
  blastula::blocks(
    blastula::block_title(translator$translate("Summaries")),
    blastula::block_text(blastula::md(
      mc_render_email(dois = dois, translator = translator, ...)$html_html
    )),
    blastula::block_title(translator$translate("Individual Results")),
    blastula::block_text(translator$translate(
      "You can find individual results for every DOI in the attached spreadsheet."
    )),
    blastula::block_text(
      blastula::md(
        mc_long_docs_string(
          "table.md",
          lang = translator$get_translation_language()
        )
      )
    )
  )
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
      disclaimer = block_text_centered(
        mc_long_docs_string(
          "disclaimer_fe.md",
          lang = translator$get_translation_language()
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
#' @inheritDotParams blastula::render_email
#' @export
mc_render_email <- function(dois = doi_examples$good[1:10],
                            translator = mc_translator(),
                            ...) {
  blastula::render_email(
    input = path_report_rmd(lang = translator$get_translation_language()),
    render_options = list(
      params = list(
        dois = dois,
        translator = translator
      )
    ),
    ...
  )
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
    if (is_prod()) bcc = from,
    credentials = credentials,
    ...
  )
  invisible(email) # best practice for funs called for side effects
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
          toggle_email_input_elements()
          promise_list <- email_async(
            to = input$recipient,
            dois = dois(),
            translator = translWithLang()
          )
          promises::then(
            promise_list$done,
            onFulfilled = function(value) toggle_email_input_elements()
          )
        }
      })
    }
  )
}

#' @describeIn emailReport Dis/enable all input elements in the module
toggle_email_input_elements <- function() {
  shinyjs::toggleState("recipient")
  shinyjs::toggleState("gdpr_consent")
  shinyjs::toggleState("send")
}

#' @describeIn emailReport Promise of a rendered and send email
#' Emits notifications and progress bar updates.
#' @inheritParams mc_compose_email
#' @inheritDotParams mc_compose_email
#' @inheritParams smtp_send_mc
#' @export
email_async <- function(to, translator = mc_translator(), ...) {
  shiny::showNotification(
    ui = glue::glue(
      translator$translate("Your email report is being prepared."),
      translator$translate(
        "You can close this window or wait for completion. "
      ),
      translator$translate("Remember to check your SPAM folder.")
    ),
    duration = NULL,
    id = "notifi_start",
    type = "message"
  )
  pb <- shiny::Progress$new()
  pb$set(value = 0, message = translator$translate("Starting ..."))
  # this is strictly out of order and is only needed later
  # but run here, b/c it actually need not be async,
  # so placing this here is cleaner to read
  pb$set(
    value = 1/4,
    message = translator$translate("Authenticating email relay ...")
  )
  # this is a workaround to enable async when developing on macOS
  # macOS forked processes apparently cannot read keychain (makes sense)
  # so we have to pass in the password manually
  auth_mailjet()
  mj_pw <- Sys.getenv("MAILJET_SMTP_PASSWORD")
  promise_email <- promises::future_promise(
    expr = mc_compose_email(translator = translator, ...),
    seed = TRUE
  )
  pb$set(
    value = 2/4,
    message = translator$translate("Composing email ..."),
    detail = translator$translate("This can take several minutes.")
  )
  promise_sent <- promises::then(
    promise_email,
    onFulfilled = function(value) {
      pb$set(
        value = 3/4,
        message = translator$translate("Sending email ...")
      )
      promises::future_promise(
        expr = {
          Sys.setenv("MAILJET_SMTP_PASSWORD" = mj_pw)
          smtp_send_mc(to = to, email = value, translator = translator)
        },
        seed = TRUE
      )
    }
  )
  id_notifi_done <- "notifi_done"
  promise_done <- promises::then(
    promise_sent,
    onFulfilled = function(value) {
      pb$set(value = 4/4, message = translator$translate("Done."))
      pb$close()
      shiny::removeNotification("notifi_start")
      shiny::showNotification(
        ui = glue::glue(
          translator$translate("Your report is in your email inbox. "),
          translator$translate("Remember to check your SPAM folder. ")
        ),
        duration = NULL,
        closeButton = TRUE,
        id = id_notifi_done,
        type = "message"
      )
      value
    }
  )
  # both are needed upstream
  list(done = promise_done, id_notifi = id_notifi_done)
}

# excel attachment ====

#' Make Spreadsheet attachment
#' Creates an excel spreadsheet with individual-level results.
#' 
#' @details `r metacheck::mc_long_docs_string("spreadsheet.md")`
#' 
#' @param dois character, *all* submitted dois
#' @param df compliance data from [cr_compliance_overview()]
#' @inheritParams writexl::write_xlsx
#' 
#' @return path to the created file
#'
#' @export
#' @family communicate
md_data_attachment <- function(dois,
                               df = cr_compliance_overview(get_cr_md(
                                 dois[is_metacheckable(dois)]
                              )),
                              path = fs::file_temp(ext = "xlsx")) {
  is_compliance_overview_list(df)
  df[["pretest"]] <- tibble::tibble(
    # writexl does not know vctrs records
    doi = as.character(biblids::as_doi(dois)),
    tabulate_metacheckable(dois)
  )
  writexl::write_xlsx(
    x = df,
    path = path
  )
}

#' Data is available
#' @noRd
is_compliance_overview_list <- function(x) {
  assertthat::assert_that(x %has_name% c("cr_overview", "cc_license_check"),
                          msg = "No Compliance Data to attach, compliance data from [cr_compliance_overview()]"
  )
}
