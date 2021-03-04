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

# wrapped cr api calls ====

#' Get Crossref Works
#'
#' Type-/length-stable, defensive and cached variant of [rcrossref::cr_works()].
#'
#' @details
#' This wrapper changes the underlying behavior as follows:
#' - vectorised by [purrr::map_dfr()]
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
    rcrossref::cr_works(x)[["data"]]
  })
  res
}
