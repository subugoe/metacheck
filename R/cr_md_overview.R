#' Get compliance overview
#'
#' @param cr crossref metadata using [get_cr_md()]
#'
#' @importFrom dplyr `%>%` filter select across one_of
#' @importFrom tidyselect matches
#'
#' @export
cr_compliance_overview <- function(cr) {
  # remove potential duplicated
  cr <- cr %>%
    distinct()
  cc_df <- license_check(cr)

  tdm_df <- cr_tdm_df(cr)
  funder_df <- cr_funder_df(cr)
  orcid_df <- cr_has_orcid(cr)

  cr_overview <- cr %>%
    mutate(has_cc = doi %in% filter(cc_df, !is.na(cc_norm))$doi,
           has_compliant_cc = doi %in% filter(cc_df, check_result == "All fine!")$doi,
           has_tdm_links = doi %in% tdm_df$doi,
           has_funder_info = doi %in% funder_df$doi,
           has_orcid = doi %in% orcid_df$doi,
           has_open_abstract = unlist(across(any_of("abstract"), ~ !is.na(.x))),
           has_open_refs = unlist(across(any_of("reference"), ~ sapply(.x, is.data.frame)))
    ) %>%
    select(doi, container_title = container.title, publisher, issued, issued_year, contains("has_"))
  if(!"has_open_abstract" %in% colnames(cr_overview)) {
    cr_overview$has_open_abstract <- FALSE
  }
  if(!"has_open_refs" %in% colnames(cr_overview)) {
    cr_overview$has_open_refs <- FALSE
  }
  list(cr_overview = cr_overview, cc_license_check = cc_df, tdm = tdm_df, funder_info = funder_df)
}
#' Check for ORCIDs
#'
#' @importFrom purrr map
cr_has_orcid <- function(cr) {
  cr %>%
    select(doi, author) %>%
    mutate(has_orcid = sapply(purrr::map(author, "ORCID"), is.character)) %>%
    filter(has_orcid == TRUE)
}
