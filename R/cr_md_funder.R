#' Get funder list from Crossref metadata
#'
#' @param cr crossref metadata using [get_cr_md()]
#'
#' @importFrom dplyr `%>%` filter select rename
#' @importFrom tidyr unnest
#'
#' @export
cr_funder_df <- function(cr) {
  if (!"funder" %in% colnames(cr)) {
    out <- NULL
  } else {
    out <- cr %>%
      dplyr::select(doi,
             container_title = container.title,
             publisher,
             issued,
             issued_year,
             funder) %>%
      tidyr::unnest(c(funder), keep_empty = TRUE) %>%
      dplyr::rename(fundref_doi = DOI, doi_asserted_by = doi.asserted.by)
  }
  out
}
