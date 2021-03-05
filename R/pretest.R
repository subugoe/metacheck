# criteria ====

#' Pretest acceptable DOIs
#'
#' @details
#' Before even checking what metadata has been deposited for a DOI,
#' a DOI has to pass a number of criteria to be eligible for metacheck.
#'
#' The below criteria are assumed to be transitive but asymmetric
#' in the order given.
#' For example, if a DOI is not found on DOI.org,
#' it is assumed that it also *cannot* be known to crossref and all later
#' predicates are also assumed to be `NA`.
#' This must necessarily be the case for, say, syntactically invalid DOIs,
#' but is more of an assumption when it comes to the consistency between
#' different data sources (say, DOI.org and Crossref).
#'
#' @inheritParams biblids::as_doi
#' @param... Additional arguments passed to the predicate functions.
#'
#' @return
#' A tibble with one column for each of the predicate results.
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
#'     registration agency (per doi.org).
#' 1. `cr_md`
#'     whether remaining DOIs have metadata on Crossref.
#'
#' `NA` can indicate that the test:
#'  - was not applicable, because a previous predicate was `FALSE`
# TODO mention here alternative reason server failure, if safely is implemented
#' @family import
#' @name pretest
NULL

#' @describeIn pretest Tabulate results
#' @export
tabulate_metacheckable <- function(x, ...) {
  x <- biblids::as_doi(x)
  tibble::tibble(
    `not_missing` = !is.na(x),
    # repeating the column names in the below is inelegant and unnecessary
    # but proper FP design (purrr::reduce? functional op?) would be hard to read
    # this will be refactored for
    # https://github.com/subugoe/metacheck/issues/169
    `unique` = lazily(purrr::negate(duplicated))(x, `not_missing`),
    `within_limits` = lazily(is_in_limit, ...)(x, `unique`),
    `doi_org_found` = lazily(biblids::is_doi_found)(x, `within_limits`),
    `resolvable` = lazily(biblids::is_doi_resolvable)(x, `doi_org_found`),
    `from_cr` = lazily(biblids::is_doi_from_ra, "Crossref")(x, `resolvable`),
    # should singl header first https://github.com/subugoe/metacheck/issues/176
    `cr_md` = lazily(is_doi_cr_md)(x, `from_cr`),
    `article` = lazily(is_doi_cr_type, "journal-article")(x, `cr_md`),
  )
}

#' @describeIn pretest Are all predicates `TRUE`?
#' @export
is_metacheckable <- function(x, ...) {
  tabulate_metacheckable(x) %>%
    purrr::pmap_lgl(all)
}

#' @describeIn pretest Assert metacheckability
#' @export
assert_metacheckable <- function(x, ...) {
  if (!all(is_metacheckable(x, ...))) {
    rlang::abort(c(
      "Not all DOIs are eligible for metacheck",
      "Use `tabulate_metacheckable()` for further diagnosis."
    ))
  }
  invisible(x)
}

# reporting ====

#' @describeIn pretest Report summary in markdown
#' @export
report_metacheckable <- function(x, ...) {
  tabulate_metacheckable(x, ...) %>%
    purrr::imap_chr(report_metacheckable1) %>%
    glue::glue_collapse(sep = "\n")
}

#' Write markdown for *one* logical vector
#' @param x A logical vector.
#' @param desc Criterion name.
#' @noRd
report_metacheckable1 <- function(x, desc) {
  stopifnot(rlang::is_logical(x))
  stopifnot(rlang::is_scalar_character(desc))
  glue::glue(
    "- Davon erf\U00FCllen {n_good(x)} ({round(percent_good(x))}%) ",
    "das Kriterium `{desc}` (**{n_bad(x)}** ausgeschlossen)"
  )
}

#' Summarise logical vectors from transitive and asymmetrical predicates
#' Slightly more complicated, because we only care about `TRUE`/`FALSE`.
#' `NA` is always dropped, because it may stem from an upstream `FALSE`.
#' @inheritParams report_metacheckable1
#' @name summarise_taps
#' @noRd
NULL

#' @describeIn summarise_taps Percent good
#' @noRd
percent_good <- function(x) n_good(x) / n_total(x) * 100

#' @describeIn summarise_taps Count good
#' @noRd
n_good <- function(x) sum(x, na.rm = TRUE)

#' @describeIn summarise_taps Count bad
#' @noRd
n_bad <- function(x) n_total(x) - n_good(x)

#' @describeIn summarise_taps Count total *possible*
#' @noRd
n_total <- function(x) (length(x) - sum(is.na(x)))

# custom predicates ====

#' @describeIn pretest
#' Is the DOI in the limit?
#' @param limit
#' Scalar integer, giving the number of DOIs to be submitted to the metacheck.
#' @export
is_in_limit <- function(x, limit = 1000L) 1:length(x) <= limit

#' @describeIn pretest
#' Is the DOI registered by Crossref?
#' @details
#' Potentially duplicates [biblids::is_doi_from_ra()],
#' or may give subtly different results.
#' Currently not in use.
#' See https://github.com/subugoe/metacheck/issues/174.
#' @inheritParams biblids::is_doi_from_ra
#' @noRd
is_doi_from_ra_cr <- function(x, ra = "Crossref") {
  ra <- rlang::arg_match(ra, values = biblids::doi_ras())
  res <- rcrossref::cr_agency(dois = x)
  if (length(x) == 1) {
    # arrgh rcrossref is very much not type stable
    res <- list(res)
  }
  res %>%
    purrr::map_chr(c("agency", "label"), .default = NA_character_) %>%
    vctrs::vec_equal(., ra)
}

#' @describeIn pretest
#' Is there metadata for the DOI on Crossref?
#' @export
is_doi_cr_md <- function(x) {
  x <- biblids::as_doi(x)
  # crossref is not length stable
  # will simply drop rows for which no metadata is found with a warning
  # suppressing these warnings is a bit dangerous
  # better way would  be to explicitly ask for header of singleton
  # as per https://github.com/subugoe/metacheck/issues/176
  dois_with_md <- suppressWarnings(
    biblids::as_doi(rcrossref::cr_works(as.character(x))[["data"]][["doi"]])
  )
  vctrs::vec_in(x, dois_with_md)
}

#' @describeIn pretest
#' Is the DOI a type (per Crossref)?
#' @param type
#' Character scalar, must be one of the types from [rcrossref::cr_types()].
#' @export
is_doi_cr_type <- function(x, type = types_allowed) {
  x <- biblids::as_doi(x)
  type <- rlang::arg_match(type, values = types_allowed)
  res <- rcrossref::cr_works(as.character(x))[["data"]][["type"]]
  res == type
}

#' Allowed types
#' By placing this outside of funciton, it only gets run at buildtime.
#' @noRd
types_allowed <- rcrossref::cr_types()[["data"]][["id"]]

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

# helpers ====
#' Adverb to let predicate functions default to `NA` for `x[x1]`
#'
#' @param .p A predicate function.
#' @inheritParams pretest
#' @noRd
lazily <- function(.p, ...) {
  function(x, x1) {
    stopifnot(rlang::is_logical(x1))
    x1[is.na(x1)] <- FALSE # protect below logic
    res <- rep(NA, length(x))
    # weird but necessary protection; we're done when all are FALSE
    if (!any(x1)) {
      return(res)
    }
    res[x1] <- rlang::exec(.p, x[x1], ...)
    res
  }
}
