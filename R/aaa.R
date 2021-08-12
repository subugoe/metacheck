#' Authorise crossref requests
#'
#' @param user,token
#' A character string used to authenticate into higher performance API pools.
#'
#' @family helpers
#'
#' @export
#'
# TODO this should really live in the crossref client
# https://github.com/subugoe/metacheck/issues/248
auth_cr <- function(user = get_cr_user(), token = get_cr_token()) {
  Sys.setenv(crossref_email = user)
  Sys.setenv(crossref_plus = token)
}

#' @describeIn auth_cr Get the email address to be used in the request `User-Agent` header.
#' If set, you can access the ["polite pool"](https://github.com/CrossRef/rest-api-doc/#etiquette) of the API.
#'
#' In this order, returns the first hit of:
#'
#' 1. `crossref_email` environment variable, as used by crossref R client,
#' 1. [`GITHUB_ACTOR`](https://docs.github.com/en/actions/reference/environment-variables) environment variable (set on GitHub Actions),
#' 1. git user email address for the repo at the working directory (requires git to be configured),
#' 1. `NULL` with a warning.
#' @export
get_cr_user <- function() {
  if (Sys.getenv("crossref_email") != "") {
    return(Sys.getenv("crossref_email"))
  }
  if (Sys.getenv("GITHUB_ACTOR") != "") {
    return(Sys.getenv("GITHUB_ACTOR"))
  }
  if (gert::user_is_configured()) {
    cf <- gert::git_config()
    return(as.character(cf[cf$name == "user.email", "value"]))
  } else {
    warning(
      "No crossref user could be found. ",
      "You may not be in the 'polite' pool and performance may be degraded."
    )
    return(NULL)
  }
}

#' @describeIn auth_cr Get the token to authenticate into the Crossref plus API tool.
#'
#' In this order, returns the first hit of:
#'
#' 1. `crossref_plus` environment variable,
#'     as used by crossref R client
#'     (recommended only for secure environment variables in the cloud),
#' 1. an entry in the OS keychain manager for `service` and `username`,
#' 1. `NULL` with a warning.
#'
#' @param service,username
#' A character string giving the service and username under which the token can be found in the OS keychain.
#'
#' @export
get_cr_token <- function(service = "https://api.crossref.org", username = get_cr_user()) {
  if (Sys.getenv("crossref_plus") != "") {
    Sys.getenv("crossref_plus")
  } else {
    tryCatch(
      expr = keyring::key_get(service = service, username = username),
      error = function(x) {
        warning(
          "No crossref plus token could be found. ",
          "Performance may be degraded."
        )
      }
    )
  }
}
