#' Funder metrics
#'
#' Presents funders linked to publications in Crossref metadata
#'
#' Publishers can share more than one funder link per record using Crossref metadata.
#' This function applies full counting, where the funder is counted onced per article.
#' Relative number is calculated by the number of checked articles.
#' Articles without funder information are tagged as "No funder links found".
#'
#' @param funder_info tibble obtained with [cr_funder_df()] or [cr_compliance_overview()]
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
#  out <- cr_compliance_overview(req)
#'
#' # Obtain funder metrics overview
#' funder_metrics(out$funder_info)
#' }
#' @keywords internal
funder_metrics <- function(funder_info = NULL) {
  is_cr_funder_df(funder_info)

  if(nrow(funder_info[is.na(funder_info[["name"]]),]) == nrow(funder_info)) {
    out <- dplyr::mutate(funder_info, name = "No funding info")
  } else if (length(unique(funder_info$name)) > 5) {
    out <- funder_info %>%
    mutate(name = ifelse(is.na(.data$name), "No funding info", .data$name)) %>%
    mutate(name = forcats::fct_lump_prop(.data$name, prop = 0.03, other_level = "Other funders")) %>%
    mutate(name = forcats::fct_infreq(.data$name)) %>%
    mutate(name = forcats::fct_relevel(.data$name, "Other funders", after = Inf)) %>%
    mutate(name = forcats::fct_relevel(.data$name, "No funding info", after = Inf))
  } else {
    out <-funder_info %>%
      mutate(name = ifelse(is.na(.data$name), "No funding info", .data$name)) %>%
      mutate(name = forcats::fct_infreq(.data$name)) %>%
      mutate(name = forcats::fct_relevel(.data$name, "No funding info", after = Inf))
  }
  ind <- out %>%
    group_by(indicator = .data$name) %>%
    summarise(value = n_distinct(.data$doi)) %>%
    dplyr::ungroup() %>%
    mutate(prop = .data$value / length(unique(funder_info$doi)) * 100)
  return(ind)
}

#' Check if funder compliance data is provided
#' @noRd
is_cr_funder_df <- function(x) {
  assertthat::assert_that(x %has_name% funder_df_skeleton(),
                          msg = "No funder compliance data provided, get data using cr_funder_df() or cr_compliance_overview()")
}
