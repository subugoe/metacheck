#' @keywords internal
"_PACKAGE"

#' Start web application
#' @inheritDotParams rmarkdown::run
#' @inherit rmarkdown::run
#' @family CICD
#' @export
runMetacheck <- function(...) {
  rmarkdown::run(file = system.file("app", "index.Rmd", package = "metacheck"), ...)
}
