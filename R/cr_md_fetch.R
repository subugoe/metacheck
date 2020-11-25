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
  tt <- rcrossref::cr_works(dois = dois, .progress = .progress)[["data"]]
  if(!is.null(tt)) {
    out <- tt %>%
    mutate(issued = lubridate::parse_date_time(issued, c("y", "ymd", "ym"))) %>%
      mutate(issued_year = lubridate::year(issued))
  } else {
   out <- NULL
  }
  out
}
#' License checker
#'
#' Retrieves records from Crossref metadata where
#' the version of record (vor), i.e. publisher version
#' is provided under a Creative Commons license without delay.
#'
#' @param cr tibble with Crossref metadata retrieved from
#'   API with `rcrossref:.cr_works()`
#' @importFrom tidyr unnest
#' @importFrom dplyr `%>%` select mutate filter
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
        delay.in.days == 0)
  return(license_df)
}
#' Obtain records with non-compliant license information
#'
#' @description In case license metadata do not comply, what are the reasons:
#'   - Did the publisher provide license metadata for the article?
#'   - Is the article provided under a CC license?
#'   - Did the CC license apply immediately after publication?
#'
#' @param cr tibble with non-compliant license metadata retrieved from the
#'   Crossref API with `rcrossref:.cr_works()`
#' @importFrom tidyr unnest
#' @importFrom dplyr `%>%` select filter
#'
#' @export
license_report <- function(cr) {
  faulty_case <- cr %>%
    select(doi, license) %>%
    unnest(cols = license)
  # Are license metadata available?
  out <- tibble::tibble(doi = unique(faulty_case$doi))
  if (!any(faulty_case[["content.version"]] == "vor")) {
    reason <- "No license metadata available for published version (version of record)"
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
      "Difference between publication date and the CC license's start_date, suggesting delayed OA publication"
  }
  out$reason <- reason
  return(out)
}
#' Normalise license info from Crossref
#'
#' @param cr tibble with non-compliant license metadata retrieved from the
#'   Crossref API with `rcrossref:.cr_works()`
#' @importFrom dplyr `%>%` select filter
#'
#' @export
license_normalise <- function(cr) {
 license_val(cr) %>%
    mutate(license = URL) %>%
    mutate(license = gsub(".*creativecommons.org/licenses/", "cc-", license)) %>%
    mutate(license = gsub("/3.0*", "", license)) %>%
    mutate(license = gsub("/4.0", "", license)) %>%
    mutate(license = gsub("/2.0*", "", license)) %>%
    mutate(license = gsub("/uk/legalcode", "", license)) %>%
    mutate(license = gsub("/igo", "", license)) %>%
    mutate(license = gsub("/legalcode", "", license)) %>%
    mutate(license = toupper(license)) %>%
    mutate(license = gsub("CC-BY-NCND", "CC-BY-NC-ND", license)) %>%
    mutate(license = gsub("/", "", license)) %>%
    mutate(license = tolower(license))
}
