# criteria ====

#' Pretest acceptable DOIs
#' 
#' DOIs have to meet some pretests to have a meaningful metadata compliance.
#'
#' @details
#' These criteria are tested,
#' and assumed to be transitive but asymmetric in the order given.
#' For example, if a DOI is not found on DOI.org,
#' it is assumed that it also *cannot* be known to Crossref.
#'
#' This must necessarily be the case for, say,
#' syntactically invalid DOIs (which cannot have metadata),
#' but is more of an assumption when it comes to the consistency between
#' different data sources.
#' For example, it is conceivable, though implausible,
#' that a DOI might not resolve on DOI.org,
#' but is still listed on Crossref.
#' 
#' For details about DOI predicates ([is.na()] etc.), see [biblids::doi()].
#' For details about custom metacheck predicates, 
#' see [metacheck::mc_predicates()].
#' 
# TODO explain that this is being run one by one (hence oddness about uniqueness)
#'
#' @param... Additional arguments passed to the predicate functions.
#'
#' @return
#' `TRUE` indicates that the test passes the criterion, `FALSE` otherwise.
#' `NA` can indicates that the test was not applicable, 
#' because a previous predicate was `FALSE`.
#' 
#' @examples
#' pretests()
#' @family import
#' @export
pretests <- function(...) {
  tibble::tribble(
    ~name, ~fun, ~desc,
    
    "not_missing",
    purrr::negate(is.na),
    "DOIs must not be missing values.",

    "unique",
    purrr::negate(duplicated),
    "DOIs must be unique.",

    "within_limits",
    purrr::partial(is_in_limit, ...),
    "Number of DOIs must be within the allowed limit.",

    "doi_org_found",
    memoised_is_doi_found,
    "DOIs must be resolveable on DOI.org.",

    "from_cr",
    purrr::partial(memoised_is_doi_from_ra, ra = "Crossref"),
    "DOIs must have been registered by the Crossref registration agency (RA).",

    "cr_md",
    is_doi_cr_md,
    "DOIs must have metadata on Crossref.",

    "article",
    purrr::partial(is_doi_cr_type, type = "journal-article"),
    "DOIs must resolve to a journal article."
  )
}

#' @describeIn pretests Tabulate results
#' @inheritParams biblids::as_doi
#' @export
tabulate_metacheckable <- function(x, ...) {
  x <- biblids::as_doi(x)
  lazyfuns <- purrr::map(pretests(...)$fun, lazily)
  # create empty res object
  res <- tibble::tibble(doi = x)
  prev <- rep_len(TRUE, length(x))
  pb <- progressr::progressor(
    along = lazyfuns,
    message = "Running pretests ...",
    label = "pretests"
  )
  for (i in 1:length(lazyfuns)) {
    pb()
    curr <- lazyfuns[[i]](x, prev)
    res <- tibble::add_column(res, curr, .name_repair = "minimal")
    prev <- curr
  }
  res <- res[-1]
  names(res) <- pretests()$name
  res
}

#' @describeIn pretests Are all predicates `TRUE`?
#' @export
is_metacheckable <- function(x, ...) {
  tabulate_metacheckable(x) %>%
    purrr::pmap_lgl(all)
}

#' @describeIn pretests Assert metacheckability
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

#' @describeIn pretests Report summary in markdown
#' @inheritParams draft_report
#' @export
report_metacheckable <- function(x, lang = mc_langs, ...) {
  lang <- rlang::arg_match(lang)
  purrr::pmap_chr(
    .l = list(
      x = tabulate_metacheckable(x, ...),
      name = pretests()$name,
      desc = pretests()$desc
    ),
    .f = report_metacheckable1,
    lang = lang
  ) %>%
    glue::glue_collapse(sep = "\n")
}

#' Write markdown for *one* logical vector
#' @param x A logical vector.
#' @param name Criterion name.
#' @param desc Criterion description.
#' @inheritParams draft_report
#' @noRd
report_metacheckable1 <- function(x, name, desc, lang = mc_langs) {
  lang <- rlang::arg_match(lang)
  transl <- metacheck::mc_translator()
  transl$set_translation_language(lang)
  stopifnot(rlang::is_logical(x))
  stopifnot(rlang::is_scalar_character(desc))
  desc_translated <- transl$translate(desc)
  # doing this via i18n would be too cumbersome with glue
  switch(
    lang,
    "en" = glue::glue(
      "- {n_good(x)} ({round(percent_good(x))}%) thereof fulfill the ",
      "criterion `{name}`: *{desc_translated}* ",
       "(**{n_bad(x)}** dropped.)"
    ),
    "de" = glue::glue(
      "- Davon erf\U00FCllen {n_good(x)} ({round(percent_good(x))}%) ",
      "das Kriterium `{name}`: *{desc_translated}* ",
      "(**{n_bad(x)}** ausgeschlossen.)"
    )
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

#' Metacheck custom predicates
#' @family transform
#' @name mc_predicates
NULL

#' @describeIn mc_predicates
#' Is the DOI in the limit?
#' @inheritParams biblids::as_doi
#' @param limit
#' Scalar integer, giving the number of DOIs to be submitted to the metacheck.
#' @export
is_in_limit <- function(x, limit = getOption("mc_limit", 1000L)) {
  1:length(x) <= limit
}

#' @describeIn mc_predicates
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
  # this call is slow and is never reused,
  # so there's no point caching it
  res <- rcrossref::cr_agency(dois = x)
  if (length(x) == 1) {
    # arrgh rcrossref is very much not type stable
    res <- list(res)
  }
  res %>%
    purrr::map_chr(c("agency", "label"), .default = NA_character_) %>%
    vctrs::vec_equal(., ra)
}

#' @describeIn mc_predicates
#' Is there metadata for the DOI on Crossref?
#' @export
is_doi_cr_md <- function(x) {
  x <- biblids::as_doi(x)
  # crossref is not length stable
  # will simply drop rows for which no metadata is found with a warning
  # suppressing these warnings is a bit dangerous
  # better way would  be to explicitly ask for header of singleton
  # as per https://github.com/subugoe/metacheck/issues/176
  dois_with_md <- looped_possibly_cr_works_field(x, "doi")
  vctrs::vec_in(x, dois_with_md)
}

#' @describeIn mc_predicates
#' Is the DOI a type (per Crossref)?
#' @param type
#' Character scalar, must be one of the types from [rcrossref::cr_types()].
#' @export
is_doi_cr_type <- function(x, type = types_allowed) {
  x <- biblids::as_doi(x)
  type <- rlang::arg_match(type, values = types_allowed)
  res <- looped_possibly_cr_works_field(x, "type")
  res == type
}

#' Allowed types
#' By placing this outside of function, it only gets run at buildtime.
#' @noRd
types_allowed <- {
  stopifnot(curl::has_internet())
  auth_cr()
  rcrossref::cr_types()[["data"]][["id"]]
}

# helpers ====
#' Adverb to let predicate functions default to `NA` for `x[x1]`
#'
#' @param .p A predicate function.
#' @inheritParams pretests
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
