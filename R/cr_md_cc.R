#' Extract and validate Crossref license metadata
#'
#' Workflow to check for compliant open content license metadata in Crossref.
#' License metadata is considered as compliant, if a Creative Commons
#' license is provided for the version-of-record without delay indicated
#' by the license date.
#'
#' @param cr crossref metadata using [get_cr_md()]
#' @family transform
#' @export
license_check <- function(cr) {
  if (!"license" %in% colnames(cr)) {
    out_template <- tibble::tibble(
      cc_norm = NA,
      check_result = "No Creative Commons license found",
      license_url = NA,
      content_version = NA,
      license_date = NA,
      delay_in_days = NA
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
    miss_df <- anti_join(cr, by_df, by = "doi") %>%
      mutate(check_result = "No Creative Commons license found") %>%
      select(.data$doi, .data$check_result)
    license_all_df <- bind_rows(by_df, miss_df) %>%
      rename(
        license_url = .data$URL,
        content_version = .data$content.version,
        license_date = .data$date,
        delay_in_days = .data$delay.in.days
      )
    # add some more crossref metadata
    out <- cr %>%
      select(one_of(
        "doi",
        "container.title",
        "publisher",
        "issued",
        "issued_year"
      )) %>%
      left_join(license_all_df, by = "doi") %>%
      distinct()
  }
  return(out)
}

#' Extract and normalize license info from Crossref metadata
#' @inheritParams license_check
#' @family transform
#' @export
get_license_md <- function(cr) {
  if ("license" %in% colnames(cr))
    cr %>%
    select(.data$doi, .data$license) %>%
    unnest(c(license), keep_empty = TRUE) %>%
    mutate(cc_norm = stringi::stri_extract(.data$URL, regex = "by.*?/") %>%
             gsub("/", "", .)
           )
}

#' Extract records with compliant CC license metadata
#'
#' @details In order to be compliant,
#'   CC license has to apply to version of record and must be valid
#'   without delay.
#' @param license_df data frame with licenses
#'
get_compliant_cc <- function(license_df) {
  license_df %>%
    filter(
      # is cc
      !is.na(.data$cc_norm),
      # applies to version of record
      .data$content.version == "vor",
      # valid without delay
      .data$delay.in.days == 0) %>%
    mutate(check_result = "All fine!")
}

#' Extract records with CC license not applied to version of records
#'
#' In order to be compliant, CC license has to apply to version of
#' record and must be valid without delay.
#'
#' @inheritParams get_compliant_cc
#' @param compliant_dois DOIs representing records with valid CC info
#' @family transform
#' @export
vor_issue <- function(license_df, compliant_dois) {
  license_df %>%
    filter(
      .data$content.version != "vor",
      .data$delay.in.days == 0,
      # has CC license
      !is.na(.data$cc_norm),!.data$doi %in% compliant_dois
    ) %>%
    mutate(check_result =
             "No Creative Commons license metadata found for version of record"
    )
}
#' Extract records with license delay
#'
#' @details Obtain records with CC license where license start_date
#'   and earliest publication date for the version of records
#'   differs, suggesting delayed CC license provision.
#' @param license_df normalized license metadata from [get_license_md()]
#'
#' @importFrom dplyr `%>%` mutate filter
#' @export
get_delayed_license <- function(license_df) {
  license_df %>%
    filter(.data$content.version == "vor", !is.na(.data$cc_norm) &
             .data$delay.in.days > 0) %>%
    mutate(check_result =
             "Difference between publication date and the CC license's start_date suggests delayed OA provision"
    )
}
