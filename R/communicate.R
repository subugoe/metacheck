#' Start web application
#' @inheritDotParams rmarkdown::run
#' @inherit rmarkdown::run
#' @family communicate
#' @export
runMetacheck <- function(...) {
  rmarkdown::run(
    file = system.file("app", "index.Rmd", package = "metacheck"),
    ...
  )
}

# shiny modules ====

#' Enter metacheck controls through a shiny module
#' @family communicate
#' @name mcControls
NULL

#' @describeIn mcControls Test App
#' @export
mcControlsApp <- function() {
  ui <- shiny::fluidPage(mcControlsUI(id = "test"))
  server <- function(input, output, session) {
    mcControlsServer(id = "test")
  }
  shiny::shinyApp(ui, server)
}

#' @describeIn mcControls Module UI
#' @inheritParams emailReportUI
#' @export
mcControlsUI <- function(id, translator = mc_translator) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny.i18n::usei18n(translator),
    shiny::selectInput(
      inputId = ns("lang"),
      label = translator$t("Language"),
      choices = translator$get_languages(),
      selected = "en"
    ),
    # TODO biblids could use its own translations, instead of these duplicates
    # but blocked by #270
    biblids::doiEntryUI(id = ns("dois"), translator = mc_translator),
    emailReportUI(id = ns("send"), translator = mc_translator)
  )
}

#' @describeIn mcControls Module server
#' @inheritParams emailReportServer
#' @export
mcControlsServer <- function(id, translator = mc_translator) {
  biblids::stopifnot_i18n(translator)
  shiny::moduleServer(
    id = id,
    module = function(input, output, session) {
      lang <- shiny::reactive(input$lang)
      # update language client side
      shiny::observe(shiny.i18n::update_lang(session, lang()))
      dois <- biblids::doiEntryServer(
        id = "dois",
        char_limit = 10000L,
        translator = translator,
        lang = lang
      )
      emailReportServer(id = "send", dois = dois, lang = lang)
    }
  )
}
