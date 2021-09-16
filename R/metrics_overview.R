#' Metacheck metrics overview
#'
#' Presents the metacheck core compliance measures
#'
#' The following metrics are presented (absolute and relative):
#'
#' - Creative commons license availability (`CC License`)
#' - Compliant creative commons license availability (`Compliant CC`)
#' - Support of links to full-texts for text and data mining (`TDM Support`)
#' - Metadata records with links between publications and funder information (`Funder info`)
#' - Metadata records with links between publications and ORCID  (`ORCID`)
#' - Metadata records with [Open Abstracts](https://i4oa.org/)
#' - Metadata records with [Open Citations](https://i4oc.org/)
#'
#' @param cr_overview tibble obtained with [cr_compliance_overview()]

#' @importFrom tidyr pivot_longer
#'
#' @export
#'
#' @examples \dontrun{
#' ## Some DOIs from OA articles
#' my_dois <- c("10.5194/wes-2019-70", "10.1038/s41598-020-57429-5",
#'   "10.3389/fmech.2019.00073", "10.1038/s41598-020-62245-y",
#'   "10.1109/JLT.2019.2961931")
#'
#' # Workflow:
#' # First, obtain metadata from Crossref API
#' req <- get_cr_md(my_dois)
#'
#' # Then, check article-level compliance
#  out <- cr_compliance_overview(my_dois)
#'
#' # Finally, obtain compliance metrics overview
#' metrics_overview(out)
#' }
#' @keywords internal
metrics_overview <- function(cr_overview = NULL) {
  is_cr_overview_df(cr_overview)

  cr_overview %>%
    dplyr::count(
      `CC License` = length(which(.data$has_cc)),
      `Compliant CC` = length(which(.data$has_compliant_cc)),
      `TDM Support` = length(which(.data$has_tdm_links)),
      `Funder info` = length(which(.data$has_funder_info)),
      `ORCID` = length(which(.data$has_orcid)),
      `Open Abstracts`  = length(which(.data$has_open_abstract)),
      `Open Citations` = length(which(.data$has_open_refs))
    ) %>%
    tidyr::pivot_longer(!n) %>%
    dplyr::mutate(prop = .data$value / n * 100) %>%
    dplyr::select(indicator = .data$name, .data$value, .data$prop)
}

#' Check if overview data is provided
#' @noRd
is_cr_overview_df <- function(x) {
  assertthat::assert_that(x %has_name% overview_df_skeleton(),
                          msg = "No compliance measures are provided, get data using cr_compliance_overview()")
}
