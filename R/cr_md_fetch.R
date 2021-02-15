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
