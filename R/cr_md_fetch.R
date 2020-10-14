#' Get Crossref metadata from API
#'
#' @param dois character vector with DOIs
#'
#' @importFrom rcrossref cr_works
#' @importFrom dplyr `%>%` select mutate filter
#' @importFrom purrr map_df
#'
#' @export
get_cr_md <- function(dois) {
  rcrossref::cr_works(dois)[["data"]]
}
#'
#'   # check compliance
#'   compliant_with_license <- license_val(cr)
#'   # get non-compliant records
#'   non_compliant_dois <-
#'     dois[!tolower(dois) %in% tolower(compliant_with_license$doi)]
#'   # determine why
#'   if (!is.null(non_compliant_dois))
#'     purrr::map_df(non_compliant_dois, function(x) {
#'       dplyr::filter(cr, doi %in% non_compliant_dois) %>%
#'         license_report()
#'     })
#' }

#' #' License checker
#'
#' @param cr tibble with Crossref metadata retrieved from
#'   API with `rcrossref:.cr_works()`
#' @import dplyr
#' @importFrom tidyr unnest
#'
#' @export
#'
license_val <- function(cr) {
  if (!is.null(cr))
    license_df <- cr %>%
      select(doi, license) %>%
      unnest(cols = c(license)) %>%
      filter(# applies to version of record
        content.version == "vor",
        # has CC license
        grepl("creativecommons", URL),
        # valid without delay
        delay.in.days == 0,)
}
#' Obtain faulty DOIs
#'
#' @param cr tibble with non-compliant license metadata retrieved from the
#'   Crossref API with `rcrossref:.cr_works()`
#'
#' @export
license_report <- function(cr) {
  faulty_case <- cr %>%
    select(doi, license) %>%
    unnest(cols = license)
  # Are license metadata available?
  out <- tibble::tibble(doi = unique(faulty_case$doi))
  if (!any(faulty_case[["content.version"]] == "vor")) {
    reason <- "No license metadata for version of records"
    # Is version of record published under an CC license
  } else if (nrow(filter(
    faulty_case,
    content.version == "vor",
    grepl("creativecommons", URL)
  )) == 0) {
    reason <-
      "No Creative Commons license metadata found for version of record"
    # Do publication and license date match?
  } else {
    reason <-
      "Date of publication and Creative Commons license does not match"
  }
  out$reason <- reason
  return(out)
}
