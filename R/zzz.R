.onLoad <- function(libname, pkgname) {
  auth_cr()
  cache_api()

  memoised_possibly_cr_works_field <<- memoise::memoise(
    possibly_cr_works_field,
    cache = cache_api()
  )
  memoised_is_doi_found <<- memoise::memoise(
    biblids::is_doi_found,
    cache = cache_api()
  )
  memoised_is_doi_from_ra <<- memoise::memoise(
    biblids::is_doi_from_ra,
    cache = cache_api()
  )

  memoised_cr_works <<- memoise::memoise(insistently_cr_works, cache = cache_api())
}
