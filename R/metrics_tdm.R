#' TDM MIME-Type metrics
#'
#' Presents MIME-Types for full-text versions of version-of-records.
#'
#' Publishers can share more than one TDM-link per full-text using
#' Crossref metadata. This function applies full counting, where
#' full-texts were assigned to more than one MIME type were counted once
#' for each. Relative number is calculated by the number of checked articles.
#' Articles without compliant TDM information are tagged as
#' "No TDM links for version-of-records".
#'
#' @param tdm tibble obtained with [cr_tdm_df()] or [cr_compliance_overview()]
#' @export
#'
#' @examples
#' # First, obtain metadata from Crossref API
#' req <- get_cr_md(doi_examples$good)
#'
#' # Then, check article-level compliance
#' out <- cr_compliance_overview(req)
#'
#' # Finally, obtain TDM metrics overview
#' tdm_metrics(out$tdm)
#' @keywords internal
tdm_metrics <- function(tdm = NULL) {
  is_cr_tdm_df(tdm)
  compliant_tdm <- tdm %>%
    filter(.data$is_tdm_compliant == TRUE)

  non_compliant_tdm <- tdm[!tdm$doi %in% compliant_tdm$doi,]

  compliant_tdm %>%
    group_by(indicator = .data$content.type) %>%
    summarise(value = n_distinct(.data$doi)) %>%
    bind_rows(miss_tdm(non_compliant_tdm)) %>%
    mutate(prop = .data$value / length(unique(tdm$doi)) * 100)
}

#' Missing records with TDM info
#' @noRd
miss_tdm <- function(non_compliant_tdm = NULL) {
  non_compliant_tdm %>%
    summarize(value = n_distinct(.data$doi)) %>%
    mutate(indicator = "No TDM links for version-of-records")
}

#' Check if TDM compliance data is provided
#' @noRd
is_cr_tdm_df <- function(x) {
  assertthat::assert_that(x %has_name% tdm_df_skeleton(),
                          msg = "No TDM compliance data provided, get data using cr_tdm_df() or cr_compliance_overview()")
}
