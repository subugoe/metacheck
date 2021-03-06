#' Get Crossref metadata from API
#'
#' @inheritParams cr_works2
#' @family import
#' @export
get_cr_md <- function(x) {
  assert_metacheckable(x)
  tt <- cr_works2(x)
  out <- tt %>%
    mutate(issued = lubridate::parse_date_time(issued, c("y", "ymd", "ym"))) %>%
    mutate(issued_year = lubridate::year(issued))
  out
}

# wrapped cr api calls ====

#' Get Crossref Works
#'
#' Type-/length-stable, defensive and cached variant of [rcrossref::cr_works()].
#'
#' @details
#' This wrapper changes the underlying behavior as follows:
#' - vectorised by [purrr::map_dfr()]
#' - all warnings and empty returned rows are raised to errors
#' - returns type stably and length stably (in rows)
#' - caches *individual* DOI results
#' - retries on failed attempts
#' - returns only the data element
#'
#' This function is still *defensive*;
#' it will error out if attempts fail or inputs are bad.
#' That is what makes it type stable/length stable.
#' It is the callers responsibility to use [purrr::possibly()],
#' and recover from errors by giving some `otherwise` default.
#' This cannot be done here,
#' because the caller must determine what a useful default is.
#' This weirdness can be resolved when we always test
#' and return individual fields as per
#' https://github.com/subugoe/metacheck/issues/183.
#'
#' @inheritParams biblids::as_doi
#' @inheritDotParams rcrossref::cr_works
#' @family import
#' @keywords internal
cr_works2 <- function(x, ...) {
  x <- biblids::as_doi(x)
  # remove this hackfix https://github.com/subugoe/metacheck/issues/182
  x <- as.character(x)
  res <- purrr::map_dfr(.x = as.character(x), function(x) {
    memoised_cr_works(dois = x)[["data"]]
  })
  res
}

#' Helper for predicate functions
#' @noRd
looped_possibly_cr_works_field <- function(x, field, ...) {
  x <- biblids::as_doi(x)
  # remove this hackfix https://github.com/subugoe/metacheck/issues/182
  x <- as.character(x)
  res <- purrr::map_chr(
    x,
    memoised_possibly_cr_works_field,
    field = field,
    ...
  )
  res
}

#' Only work with one DOI
#' Preventing foot guns, one at a time.
#' @noRd
lonely_cr_works <- function(dois, ...) {
  stopifnot(rlang::is_scalar_character(dois))
  rcrossref::cr_works(dois = dois, ...)
}

#' Capture warning message
#' @noRd
quiet_cr_works <- purrr::quietly(lonely_cr_works)

#' Raise an error if there's a warning or an empty df
#' @noRd
prickly_cr_works <- function(...) {
  res <- quiet_cr_works(...)
  if (length(res$warnings) != 0L) {
    # do not accept any warnings
    # notice that even a 404 may resolve with a retry
    # as per https://github.com/subugoe/metacheck/issues/181
    # though one should usually avoid a retry in that case
    # 404 will be best avoided by first checking singleton header
    # https://github.com/subugoe/metacheck/issues/176
    # once that is done, 404s should get special treatment here
    # and NOT trigger a retry
    rlang::abort(res$warnings)
  }
  if (nrow(res$result$data) != 1) {
    rlang::abort("Can't find one row in `$data`.")
  }
  res$result
}

#' Rate for retrying
#' @noRd
rate <- purrr::rate_backoff()

#' Retry on error
#' @noRd
insistently_cr_works <- purrr::insistently(
  prickly_cr_works,
  rate = rate,
  quiet = !interactive()
)

#' Cache results
#' Lives in zzz.R to stick to convention.
#' @noRd
NULL

#' Retrieve some field
#' This needs to call memoised version,
#' because we want to always re-use the same entire result object.
#' @param Integer scalar of a field (column) in cr_works results
#' @noRd
cr_works_field <- function(dois, field, ...) {
  res <- memoised_cr_works(dois, ...)[["data"]][[field]]
  stopifnot(rlang::is_scalar_vector(res))
  res
}

#' Possibly retrieve field
#' @noRd
possibly_cr_works_field <- purrr::possibly(
  cr_works_field,
  otherwise = NA,
  quiet = !interactive()
)

#' Cache results
#' Lives in zzz.R to stick to convention
#' @details
#' possibly_cr_works_field also needs to be cached
#' so that `NA` results are cached.
#' Above, lower level caching can only cache when there *is* a result
#' Conditions cannot be cached.
#' @noRd
NULL

#' Helper for use in predicates.
#' Eventually this should be used for everything as per
#' https://github.com/subugoe/metacheck/issues/183.
