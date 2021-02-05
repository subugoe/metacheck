#' Extract and validate Crossref license metadata
#'
#' Workflow to check for compliant open content license metadata in Crossref.
#' License metadata is considered as compliant, if a Creative Commons license is provided for the version-of-record without delay indicated by the license date.
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
      delay_in_days = NA,
    )
    out <- bind_cols(doi = cr$doi, out_template)
  } else {
    # extract license md
    license_df <- get_license_md(cr)
    # validation steps
    # compliant, i.e cc version-of-record without delay
    compliant_cc <- get_compliant_cc(license_df)
    # cc, but not explicitly attached to version-of-record
    vor_issue_df <- vor_issue(license_df, compliant_cc$doi)
    # bring those together
    by_df <- bind_rows(compliant_cc, vor_issue_df)
    delayed_df <- license_df %>%
      filter(!doi %in% by_df$doi, !is.na(cc_norm) &
               delay.in.days > 0) %>%
      mutate(check_result = "Difference between publication date and the CC license's start_date suggests delayed OA provision")
    # add them to checked records
    by_delayed_df <- bind_rows(by_df, delayed_df)
    # No CC
    miss_df <- anti_join(license_df, by_delayed_df, by = "doi") %>%
      mutate(check_result = "No Creative Commons license found")
    # bring it altogether
    license_all_df <- miss_df %>%
      distinct(doi, cc_norm, check_result) %>%
      bind_rows(by_delayed_df) %>%
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
#' @inheritParams license_check
#' @family transform
#' @export
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
#' In order to be compliant, CC license has to apply to version of record and must be valid without delay.
#' @param license_df normalized license metadata from [license_check()]
#' @family transform
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
#' In order to be compliant, CC license has to apply to version of record and must be valid without delay.
#' @inheritParams get_compliant_cc
#' @param compliant_dois DOIs representing records with valid CC info
#' @family transform
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
