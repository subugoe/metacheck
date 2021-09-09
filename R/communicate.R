#' Start web application
#' @inheritDotParams shiny::runApp
#' @family communicate
#' @export
runMetacheck <- function(...) shiny::runApp(appDir = mcApp(), ...)

#' Shiny webapp for metacheck
#' @family communicate
#' @export
mcApp <- function() {
  future::plan(future::multicore, workers = 20L)
  shiny::shinyApp(
    ui = mcAppUI(),
    server = mcAppServer
  )
}

#' @describeIn mcApp UI
#' @noRd
mcAppUI <- function() {
  shiny::fillPage(
    theme = mc_theme(),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        mcControlsUI(id = "webapp")
      ),
      shiny::mainPanel(
        shiny::p("foo")
      )
    )
  )
}

#' @describeIn mcApp Server
#' @noRd
mcAppServer <- function(input, output, session) {
  mcControlsServer(id = "webapp")
}

# TODO move to subugoetheme https://github.com/subugoe/metacheck/issues/271
mc_theme <- function() {
  bslib::bs_theme(
    version = 4,
    bootswatch = "cosmo",
    bg = subugoetheme::ugoe_pal()$primary["Weiss"],
    fg = subugoetheme::ugoe_pal()$primary["Schwarz"],
    primary = subugoetheme::ugoe_pal()$primary["Uni-Blau (HKS 41)"],
    secondary = subugoetheme::ugoe_pal()$primary["Schwarz"],
    success = subugoetheme::ugoe_pal()$faculty["Agrarwissenschaften"],
    # this is not one of the ugoe pal, but was used in the past
    # as per less in subugoetheme
    info = "#45195c",
    warning = subugoetheme::ugoe_pal()$faculty["Biologie und Psychologie"],
    danger = subugoetheme::ugoe_pal()$faculty["Jura"]
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
