#' Get funder list from Crossref metadata
#'
#' @param cr crossref metadata using [get_cr_md()]
#' @family transform
#' @export
cr_funder_df <- function(cr) {
  empty_funder(cr) %>%
      dplyr::select(
        .data$doi,
        container_title = .data$container.title,
        .data$publisher,
        .data$issued,
        .data$issued_year,
        .data$funder
      ) %>%
      tidyr::unnest("funder", keep_empty = TRUE) %>%
      dplyr::rename(fundref_doi = .data$DOI, doi_asserted_by = .data$doi.asserted.by)
}

#' dirty hack to prevent for missing funder json nodes
#' https://github.com/subugoe/metacheck/issues/183
#'
#' @noRd
empty_funder <- function(cr) {
  if (!"funder" %in% colnames(cr)) {
    funder <- list(tibble::tibble(
      DOI = as.character(NA), name = as.character(NA), doi.asserted.by = as.character(NA)
    ))
    out <- mutate(cr, funder = funder)
  } else {
    out <- cr
  }
  out
}

