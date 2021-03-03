#' Get Crossref metadata from API
#'
#' @param dois character vector with DOIs
#' @inheritParams rcrossref::cr_works
#' @family import
#' @export
get_cr_md <- function(dois,
                      .progress = ifelse(interactive(), "text", "none")) {
  assert_metacheckable(dois)
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
#' 1. `unique`
#'    `FALSE` for every 2nd and later repetition of a DOI.
#'     DOIs are compared using [biblids::doi()] logic.
#' 1. `within_limits`
#'     whether remaining DOIs are within the package limit for requests.
#' 1. `doi_org_found`
#'     whether remaining DOIs are found on DOI.org,
#'     using [biblids::is_doi_found()].
#' 1. `resolvable`
#'     whether remaining DOIs are resolvable on DOI.org,
#'     using [biblids::is_doi_resolvable()].
#' 1. `from_cr`
#'     whether remaining DOIs have been deposited by the Crossref
#'     registration agency.
#'
#' `NA` can indicate that the test:
#'  - was not applicable, because a previous predicate was `FALSE`
# menion here alternative reason server failure, if safely is implemented
#' @family import
#' @export
tabulate_metacheckable <- function(x, ...) {
  x <- biblids::as_doi(x)
  tibble::tibble(
    `not_missing` = !is.na(x),
    # repeating the column names in the below is inelegant and unnecessary
    # but proper FP design (purrr::reduce? functional op?) would be hard to read
    # this will be refactored for https://github.com/subugoe/metacheck/issues/169
    `unique` = lazily(purrr::negate(duplicated))(x, `not_missing`),
    `within_limits` = lazily(is_in_limit, ...)(x, `unique`),
    `doi_org_found` = lazily(biblids::is_doi_found)(x, `within_limits`),
    `resolvable` = lazily(biblids::is_doi_resolvable)(x, `doi_org_found`),
    `from_cr` = lazily(biblids::is_doi_from_ra, "Crossref")(x, `resolvable`)
  )
}

#' @describeIn tabulate_metacheckable Are all checks `TRUE`?
#' @export
is_metacheckable <- function(x, ...) {
  purrr::pmap_lgl(tabulate_metacheckable(x), all)
}

#' @describeIn tabulate_metacheckable Assert metacheckable
#' @export
assert_metacheckable <- function(x, ...) {
  if (!all(is_metacheckable(x, ...))) {
    rlang::abort(c(
      "Not all DOIs are eligible for metacheck",
      "See `tabulate_metacheck()` for details."
    ))
  }
  invisible(x)
}

#' Limit as a predicate function
#' Just takes the first n x up to and including the limit.
#' Helpful to stay consistent with the other predicate signatures.
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

#' Helper to get percent `TRUE` of *possible* `TRUE` (i.e. dropping `NA`)
#' @noRd
percent_good <- function(x) n_good(x) / n_total(x) * 100

#' Helper to get count `TRUE`
#' @noRd
n_good <- function(x) sum(x, na.rm = TRUE)

#' Helper to get count `FALSE` (i.e. dropping `NA`)
#' @noRd
n_bad <- function(x) n_total(x) - n_good(x)

#' Helper to get count of possible `TRUE`s (i.e. dropping `NA`)
#' Necessary because raw counts are not meaningful,
#' must be compared to those *possible*, i.e. not `NA`.
#' @noRd
n_total <- function(x) (length(x) - sum(is.na(x)))

#' Write out report in prose
#' @describeIn tabulate_metacheckable Report summary in markdown
#' @noRd
report_metacheckable <- function(x) {
  dframe <- tabulate_metacheckable(x)
  glue::glue_collapse(purrr::imap_chr(dframe, report_metacheckable1), "\n")
}

#' Write prose for *one* predicate check
#' @noRd
report_metacheckable1 <- function(x, desc) {
  stopifnot(rlang::is_logical(x))
  stopifnot(rlang::is_scalar_character(desc))
  glue::glue(
    "- Davon erf\U00FCllen {n_good(x)} ({round(percent_good(x))}%) ",
    "das Kriterium `{desc}` (**{n_bad(x)}** ausgeschlossen)"
  )
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
