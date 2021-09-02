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

#' Enter metacheck inputs through a shiny module
#'
#' @family communicate
#' @name mcInput
NULL

#' @describeIn mcInput Test App
#' @export
mcInputApp <- function() {
  ui <- shiny::fluidPage(mcInputUI(id = "test"))
  server <- function(input, output, session) mcInputServer(id = "test")
  shiny::shinyApp(ui, server)
}

#' @describeIn mcInput Module UI
#' @inheritParams shiny::NS
#' @export
mcInputUI <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    biblids::doiEntryUI(id = ns("dois")),
    emailReportUI(id = ns("send"))
  )
}

#' @describeIn mcInput Module server
#' @export
mcInputServer <- function(id) {
  shiny::moduleServer(
    id = id,
    module = function(input, output, session) {
      dois <- biblids::doiEntryServer(id = "dois", char_limit = 10000L)
      emailReportServer(id = "send", dois = dois())
    }
  )
}
