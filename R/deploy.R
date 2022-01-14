#' Deploy metacheck to shinyapps.io
#' Wraps [rsconnect::deployApp]
#' @note
#' This will only work if metacheck and all its dependencies have been installed with `remotes::install_github()`
#' @family helpers
#' @export
deployAppSaio <- function() {
  rsconnect::deployApp(
    appDir = system_file2("saio"),
    appPrimaryDoc = "saio_launcher.R",
    appName = "metacheck-test",
    forceUpdate = TRUE
  )
}

#' Install metacheck dep again
#' @noRd
install_for_packrat <- function() {
  remotes::install_github(
    "subugoe/metacheck",
    ref = "deploy-2-shinyappsio",
    force = TRUE,
    dependencies = TRUE
  )
}
