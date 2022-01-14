.onLoad <- function(libname, pkgname) {
  auth_cr()
  cache_api()

  #' Cache results
  #' @details
  #' possibly_cr_works_field also needs to be cached
  #' so that `NA` results are cached.
  #' Above, lower level caching can only cache when there *is* a result
  #' Conditions cannot be cached.
  #' @noRd
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

  #' Cache results
  #' @noRd
  memoised_cr_works <<- memoise::memoise(insistently_cr_works, cache = cache_api())
}
