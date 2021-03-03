#' Get Crossref metadata from API
#'
#' @param dois character vector with DOIs
#' @inheritParams rcrossref::cr_works
#' @family ETL import
#' @export
get_cr_md <- function(dois,
                      .progress = ifelse(interactive(), "text", "none")) {
  # TODO this can be replaced by class validation
  # TODO not sure where the best place for the unique assertion is
  checkmate::assert_character(dois, any.missing = FALSE, unique = TRUE)
  tt <- rcrossref::cr_works(dois = dois, .progress = .progress)[["data"]]
  if (nrow(tt) != 0) {
    out <- tt %>%
    mutate(issued = lubridate::parse_date_time(issued, c("y", "ymd", "ym"))) %>%
      mutate(issued_year = lubridate::year(issued))
  } else {
   out <- NULL
  }
  out
}

#' Report and filter acceptable DOIs
#'
#' @details
#' Before even checking what metadata has been deposited for a DOI,
#' a DOI has to pass a number of tests to be eligible for metacheck.
#'
#' The below criteria are assumed to be transitive but asymmetric
#' in the order given.
#' For example, if a DOI is not found on DOI.org,
#' it is assumed that it is also not known to crossref and all other tests
#' are also assumed to be `NA`.
#' This must necessarily be the case for, say, syntactically invalid DOIs,
#' but is more of an assumption when it comes to the consistency between
#' different data sources.
#'
#' @inheritParams biblids::as_doi
#' @param... Additional arguments passed to predicate functions.
#'
#' @return
#' A tibble with one column for each of predicate results.
#' `TRUE` always means that a DOI passes a criterion.
#'
#' Tested in order:
#' 1. `not_na` following [biblids::doi()].
#' 2. `unique`
#'    `FALSE` for every 2nd and later repetition of a DOI.
#'     DOIs are compared using [biblids::doi()] logic.
#' 3. `within_limits`
#'     whether remaining DOIs are within the package limit for requests.
#'
#' `NA` can indicate that the test:
#'  - was not applicable, because a previous predicate was `FALSE`
# menion here alternative reason server failure, if safely is implemented
#' @family ETL import
#' @export
tabulate_metacheckable <- function(x, ...) {
  x <- biblids::as_doi(x)
  tibble::tibble(
    `not_missing` = !is.na(x),
    # repeating the column names in the below is inelegant and unnecessary
    # but proper FP design (purrr::reduce? functional op?) would be hard to read
    `unique` = lazily(purrr::negate(duplicated))(x, `not_missing`),
    `within_limits` = lazily(is_in_limit, ...)(x, `unique`)
  )
}

#' @describeIn tabulate_metacheckable Are all checks `TRUE`?
#' @export
is_metacheckable <- function(x, ...) {
  purrr::pmap_lgl(tabulate_metacheckable(x), all)
}

#' Helper to stay similar to other signatures
#' @noRd
is_in_limit <- function(x, limit = 1000L) 1:length(x) <= limit

#' Adverb to let predicate functions default to `NA` for `x[x1]`
#'
#' `x1` must be a logical vector, can have NAs.
#' @inheritParams sublettly
#' @noRd
lazily <- function(.p, ...) {
  function(x, x1) {
    stopifnot(rlang::is_logical(x1))
    x1[is.na(x1)] <- FALSE # protect below logic
    res <- rep(NA, length(x))
    res[x1] <- exec(.p, x[x1], ...)
    res
  }
}

#' Test whether DOI as metadata on Crossref
#'
#' @param doi [biblids::doi()] of length 1
#'
#' @noRd
has_cr_md <- function(doi) {
  # TODO this is a bad hackjob, and should be replaced by proper biblids code asap
  res <- suppressWarnings(rcrossref::cr_works(biblids::as_doi(doi)))
  # TODO this is a very bad proxy; we actually mean the http response code, but rcrossref doesn't readily give that
  nrow(res$data) != 0
}

#' @describeIn has_cr_md Vectorised version
#' @param dois [biblids::doi()]
#' @noRd
have_cr_md <- function(dois) purrr::map_lgl(dois, has_cr_md)
