#' Get Crossref metadata from API
#'
#' @param dois character vector with DOIs
#' @param .progress show progress bar, use "none" if no progress should be
#'   displayed
#'
#' @importFrom rcrossref cr_works
#'
#' @export
get_cr_md <- function(dois, .progress = "text") {
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

