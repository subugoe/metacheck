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
#' @inheritParams metrics_overview
#'
#' @importFrom dplyr mutate rename group_by summarise arrange desc bind_rows
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
#' # Finally, obtain TDM metrics overview
#' tdm_metrics(out)
#' # change bar chart color
#' tdm_metrics(out, .color = "green")
#' # as tibble
#' tdm_metrics(out, .gt = FALSE)
#' }
<<<<<<< HEAD
tdm_metrics <- function(.md = NULL, .gt = TRUE,  .color = "#9B0056") {
  if(is.null(.md) || !c("tdm", "cr_overview") %in% names(.md))
    stop("No TDM data available, get data using cr_compliance_overview()")
  else
  out <- .md$tdm %>%
    group_by(content.type) %>%
    summarise(value = n_distinct(doi)) %>%
    arrange(desc(value)) %>%
    bind_rows(tibble::tibble(
      content.type = "No TDM links for version-of-records", value = miss_tdm(.md))
      ) %>%
    mutate(prop = value / length(unique(.md$cr_overview$doi)) * 100) %>%
    rename(name = content.type)
  if(.gt == FALSE)
    out
  else
    ind_table_to_gt(out, prop = prop, .color = .color)
}

#' Missing records with TDM info
#' @noRd
miss_tdm <- function(.md = NULL) {
  .md$cr_overview %>%
    filter(!doi %in% .md$tdm$doi) %>%
    distinct(doi) %>%
    nrow()
}
