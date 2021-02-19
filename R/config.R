#' Metrics
#'
#' Compliance metrics must be a tibble with three columns:
#' - indicator, representing the compliance measure
#' - value, representing the article count,
#' - prop, representing percentages
#' @noRd
metrics_skeleton <- function() c("indicator", "value", "prop")

#' data columns needed to calculate overall metrics
#' @noRd
overview_df_skeleton <- function()
  c("doi", "has_cc", "has_compliant_cc", "has_tdm_links", "has_funder_info",
    "has_orcid", "has_open_abstract", "has_open_refs")

#' data columns needed to calculate TDM metrics
#' @noRd
tdm_df_skeleton <- function() c("content.version", "intended.application", "content.type", "doi")

#' data columns needed to calculate funder metrics
#' @noRd
funder_df_skeleton <- function() c("fundref_doi", "name", "doi")

#' data columns needed to calculate CC metrics
#' @noRd
cc_license_df_skeleton <- function() c("cc_norm", "check_result", "doi")
