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
