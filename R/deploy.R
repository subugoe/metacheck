#' Deploy metacheck to shinyapps.io
#' Wraps [rsconnect::deployApp]
#' @note
#' This will only work if metacheck and all its dependencies have been installed with `remotes::install_github()`
#' @family helpers
#' @export
deployAppSaio <- function() {
  rsconnect::deployApp(
    appDir = "inst/saio",
    appPrimaryDoc = "saio_launcher.R",
    appName = "metacheck",
    forceUpdate = TRUE,
    logLevel = "verbose"
  )
}

#' Helper to write env secret vars to file on saio
#' This is a pretty bad hack,
#' but saio does not have secret env vars
#' @noRd
write_env_var <- function(name) {
  value <- Sys.getenv(name)
  env_file <- fs::path("inst/saio/env_secrets.R")
  if (!fs::file_exists(env_file)) {
    fs::file_create(env_file)
  }
  write(
    x = glue::glue(
      "Sys.setenv('{name}' = '{value}')"
    ),
    file = env_file,
    append = TRUE
  )
}

#' Install metacheck dep again
#' @noRd
install_for_packrat <- function(ref = "deploy-2-shinyappsio") {
  remotes::install_github(
    "subugoe/metacheck",
    ref = ref,
    force = TRUE,
    dependencies = TRUE
  )
}
