.onLoad <- function(libname, pkgname) {
  # for details see import.R
  memoised_cr_works <<- memoise::memoise(
    insistently_cr_works,
    cache = cache_api()
  )
  memoised_possibly_cr_works_field <<- memoise::memoise(
    possibly_cr_works_field,
    cache = cache_api()
  )
  # also cache biblids calls to disc if possible
  # pretty bad hack, because this makes it double memoised
  memoised_is_doi_found <<- memoise::memoise(
    biblids::is_doi_found,
    cache = cache_api()
  )
  memoised_is_doi_from_ra <<- memoise::memoise(
    biblids::is_doi_from_ra,
    cache = cache_api()
  )
  auth_cr()
}

#' Conditionally set a cache which can be reused across sessions
#' Helpful for testing, vignettes, etc.
#' @noRd
cache_api <- function() {
  # TODO this should be removed when using BigQuery 
  # https://github.com/subugoe/metacheck/issues/236
  if (fs::dir_exists("~")) {
    # this should only work on unix compliant systems
    cachem::cache_disk(
      dir = "~/.metacheck-cache",
      max_age = 60 * 60 * 24 * 31,
      destroy_on_finalize = FALSE
    )
  } else {
    cachem::cache_mem()
  }
}

#' Authorise crossref requests
#' 
#' @param user,token
#' A character string used to authenticate into higher performance API pools.
#' 
#' @family helpers
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
  if (Sys.getenv("crossref_email") != "") return(Sys.getenv("crossref_email"))
  if (Sys.getenv("GITHUB_ACTOR") != "") return(Sys.getenv("GITHUB_ACTOR"))
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
