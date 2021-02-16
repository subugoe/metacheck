#' Get text-mining links from Crossref metadata
#'
#' Unnest TDM information for version-of-records from Crossref metadata
#'
#' @param cr crossref metadata using [get_cr_md()]
#'
#' @importFrom dplyr filter select
#' @importFrom tidyr unnest
#'
#' @export
cr_tdm_df <- function(cr) {
  if("link" %in% colnames(cr)) {
  out <- cr %>%
    select(doi, container_title = container.title, publisher, issued, issued_year, link) %>%
    unnest(cols = "link")  %>%
    filter(content.version == "vor", intended.application == "text-mining")
  } else {
    out <- NULL
  }
  out
}
