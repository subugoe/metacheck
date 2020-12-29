#' Extract and validate Crossref license metadata
#'
#' @details Workflow to check for compliant open content license metadata in Crossref.
#'   License metadata is considered as compliant, if a Creative Commons license is
#'   provided for the version-of-record without delay indicated by the license date.
#'
#' @param cr crossref metadata using [get_cr_md()]
#' @importFrom dplyr `%>%` bind_rows bind_cols filter mutate anti_join distinct left_join
#'
#' @export
license_check <- function(cr) {
  if (!"license" %in% colnames(cr)) {
    out_template <- tibble::tibble(
      cc_norm = NA,
      check_result = "No Creative Commons license found",
      license_url = NA,
      content_version = NA,
      license_date = NA,
      delay_in_days = NA,
    )
    out <- bind_cols(doi = cr$doi, out_template)
  } else {
    # extract license md
    license_df <- get_license_md(cr)
    # validation steps
    # compliant, i.e cc version-of-record without delay
    compliant_cc <- get_compliant_cc(license_df)
    # vor has cc, but time lag between issued and license date
    delayed_df <- get_delayed_license(license_df)
    vor_df <- bind_rows(compliant_cc, delayed_df)
    # cc, but not explicitly attached to version-of-record
    vor_issue_df <- vor_issue(license_df, vor_df$doi)
    # bring those together
    by_df <- bind_rows(vor_df, vor_issue_df)
    # No CC
    miss_df <- anti_join(license_df, by_df, by = "doi") %>%
      mutate(check_result = "No Creative Commons license found")
    # bring it altogether
    license_all_df <- miss_df %>%
      distinct(doi, cc_norm, check_result) %>%
      bind_rows(by_df) %>%
      select(
        doi,
        cc_norm,
        check_result,
        license_url = URL,
        content_version = content.version,
        license_date = date,
        delay_in_days = delay.in.days
      )
    # add some more crossref metadata
    out <- cr %>%
      select(doi, container_title = container.title, publisher, issn, issued, issued_year) %>%
      left_join(license_all_df, by = "doi") %>%
      distinct()
  }
  return(out)
}
#' Extract license info from Crossref metadata
#'
#' @param cr crossref metadata using [get_cr_md()]
#'
#' @importFrom dplyr `%>%` mutate filter
#' @importFrom tidyr unnest
#' @importFrom stringi stri_extract
#' @export
#'
get_license_md <- function(cr) {
  cr %>%
    select(doi, license) %>%
    unnest(c(license), keep_empty = TRUE) %>%
    mutate(cc_norm = stringi::stri_extract(URL, regex = "by.*?/") %>%
             gsub("/", "", .)
    )
}
#' Extract records with compliant CC license metadata
#'
#' @details In order to be compliant,
#'   CC license has to apply to version of record and must be valid
#'   without delay.
#'
#' @param license_df normalized license metadata from [license_df()]
#'
#' @importFrom dplyr `%>%` mutate filter
#' @export
get_compliant_cc <- function(license_df) {
  license_df %>%
    filter(# applies to version of record
      content.version == "vor",
      # has CC license
      !is.na(cc_norm),
      # valid without delay
      delay.in.days == 0) %>%
    mutate(check_result = "All fine!")
}
#' Extract records with CC license not applied to version of records
#'
#' @details In order to be compliant,
#'   CC license has to apply to version of record and must be valid
#'   without delay.
#'
#' @param license_df normalized license metadata from [license_df()]
#' @param compliant_dois DOIs representing records with valid CC info
#'
#' @importFrom dplyr `%>%` mutate filter
#' @export
vor_issue <- function(license_df, compliant_dois) {
  license_df %>%
    filter(content.version != "vor",
           delay.in.days == 0,
           # has CC license
           !is.na(cc_norm),
           !doi %in% compliant_dois
    ) %>%
    mutate(check_result = "No Creative Commons license metadata found for version of record")
}
#' Extract records with license delay
#'
#' @details Obtain records with CC license where license start_date
#'   and earliest publication date for the version of records
#'   differs, suggesting delayed CC license provision.
#' @param license_df normalized license metadata from [license_df()]
#'
#' @importFrom dplyr `%>%` mutate filter
#' @export
get_delayed_license <- function(license_df) {
  license_df %>%
    filter(content.version == "vor", !is.na(cc_norm) &
             delay.in.days > 0) %>%
    mutate(check_result = "Difference between publication date and the CC license's start_date suggests delayed OA provision")
}
