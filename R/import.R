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
