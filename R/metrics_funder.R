#' Funder metrics
#'
#' Presents funders linked to publications in Crossref metadata
#'
#' Publishers can share more than one funder link per record using
#' Crossref metadata. This function applies full counting, where the
#' funder is counted onced per article.
#' Relative number is calculated by the number of checked articles.
#' Articles without funder information are tagged as
#' "No funder links found".
#'
#' @inheritParams metrics_overview
#'
#' @importFrom dplyr mutate ungroup group_by summarise arrange desc
#'   n_distinct
#' @importFrom gt  tab_style cell_text cells_body
#' @importFrom forcats fct_lump_n fct_infreq fct_relevel
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
#' # Finally, obtain funder metrics overview
#' funder_metrics(out)
#' # change bar chart color
#' funder_metrics(out, .color = "green")
#' # as tibble
#' funder_metrics(out, .gt = FALSE)
#' }
funder_metrics <-
  function(.md = NULL,
           .gt = TRUE,
           .color = "#009999") {
    if (is.null(.md) || !"funder_info" %in% names(.md))
      stop("No funder data available, get data using cr_compliance_overview()")
    else
      out <-  .md$funder_info %>%
        mutate(name = ifelse(is.na(name), "No Funding Info", name)) %>%
        mutate(name = forcats::fct_lump_n(name, 5, other_level = "Other funders")) %>%
        mutate(name = forcats::fct_infreq(name)) %>%
        mutate(name = forcats::fct_relevel(name, "Other funders", after = Inf)) %>%
        mutate(name = forcats::fct_relevel(name, "No Funding Info", after = Inf)) %>%
        group_by(name) %>%
        summarise(value = n_distinct(doi)) %>%
        dplyr::ungroup() %>%
        mutate(prop = value / length(unique(.md$cr_overview$doi)) * 100)
    if (.gt == FALSE)
      out
    else
      ind_table_to_gt(out, prop = prop, .color = .color) %>%
        gt::tab_style(
          style = list(
            gt::cell_text(weight = "bold")
          ),
          locations = gt::cells_body(
            rows = name == "Deutsche Forschungsgemeinschaft")
        )
  }
