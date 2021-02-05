#' Get funder list from Crossref metadata
#'
#' @param cr crossref metadata using [get_cr_md()]
#' @family transform
#' @export
cr_funder_df <- function(cr) {
  if (!"funder" %in% colnames(cr)) {
    out <- NULL
  } else {
    out <- cr %>%
      select(doi,
             container_title = container.title,
             publisher,
             issued,
             issued_year,
             funder) %>%
      unnest(funder) %>%
      rename(fundref_doi = DOI, doi_asserted_by = doi.asserted.by)
  }
  out
}
