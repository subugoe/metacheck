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
#' @param .md list, returned from [cr_compliance_overview()]
#' @param .gt logical, should results be represented as styled html tables or
#'   as tibble. Default .gt = TRUE.
#' @param .color character, hex color code for styling HTML proportional bar chart
#'
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr mutate select count
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
#' req <- get_cr_md(test_dois)
#'
#' # Then, check article-level compliance
#  out <- cr_compliance_overview(req)
#'
#' # Finally, obtain compliance metrics overview
#' metrics_overview(out)
#' # change bar chart color
#' metrics_overview(out, .color = "green")
#' # as tibble
#' metrics_overview(out, .gt = FALSE)
#' }
metrics_overview <- function(.md = NULL, .gt = TRUE, .color = "#00A4A7") {
  if(is.null(.md) || !"cr_overview" %in% names(.md))
    stop("No compliance overview data provided, get data using cr_compliance_overview()")
  else
  out <- .md$cr_overview %>%
    dplyr::count(`CC License` = length(which(has_cc)),
        `Compliant CC` = length(which(has_compliant_cc)),
        `TDM Support` = length(which(has_tdm_links)),
        `Funder info` = length(which(has_funder_info)),
        `ORCID` = length(which(has_orcid)),
        `Open Abstracts`  = length(which(has_open_abstract)),
        `Open Citations` = length(which(has_open_refs))
        ) %>%
  tidyr::pivot_longer(!n) %>%
  dplyr::mutate(prop = value / n * 100) %>%
  dplyr::select(-n)
  if(.gt != TRUE)
    return(out)
  else
    out %>%
      # html table
      dplyr::mutate(prop_bar = map(prop, ~bar_chart(value = .x, .color = .color))) %>%
      ind_table_to_gt()
}

#' Embed HTML Bar Charts in gt
#'
#' <https://themockup.blog/posts/2020-10-31-embedding-custom-features-in-gt-tables/>
#'
#' @noRd
bar_chart <- function(value, .color = "red"){

  glue::glue("<span style=\"display: inline-block; direction: ltr; border-radius: 4px; padding-right: 2px; background-color: {.color}; color: {.color}; width: {value}%\"> &nbsp; </span>") %>%
    as.character() %>%
    gt::html()
}

