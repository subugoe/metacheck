#' Get compliance overview
#'
#' @param cr crossref metadata using [get_cr_md()]
#' @family transform
#' @export
cr_compliance_overview <- function(cr) {
  # remove potential duplicated
  cr <- cr %>%
    distinct()
  cc_df <- license_check(cr)

  tdm_df <- cr_tdm_df(cr)
  compliant_tdm <- filter(tdm_df,
                          .data$is_tdm_compliant == TRUE)
  funder_df <- cr_funder_df(cr)
  has_funder <- funder_df %>%
    filter(!is.na(.data$name))
  orcid_df <- cr_has_orcid(cr)

  cr_overview <- cr %>%
    mutate(
      has_cc = .data$doi %in%
        filter(cc_df, !is.na(.data$cc_norm))$doi,
      has_compliant_cc = .data$doi %in%
        filter(cc_df, .data$check_result == "All fine!")$doi,
      has_tdm_links = .data$doi %in% compliant_tdm$doi,
      has_funder_info = .data$doi %in% has_funder$doi,
      has_orcid = .data$doi %in% orcid_df$doi,
      has_open_abstract = unlist(across(any_of("abstract"), ~ !is.na(.x))),
      has_open_refs = unlist(across(
        any_of("reference"), ~ sapply(.x, empty_list)
      ))
    ) %>%
    select(
      .data$doi,
      container_title = .data$container.title,
      .data$publisher,
      .data$issued,
      .data$issued_year,
      contains("has_")
    )
  if (!"has_open_abstract" %in% colnames(cr_overview)) {
    cr_overview$has_open_abstract <- FALSE
  }
  if (!"has_open_refs" %in% colnames(cr_overview)) {
    cr_overview$has_open_refs <- FALSE
  }
  list(
    cr_overview = cr_overview,
    cc_license_check = cc_df,
    tdm = tdm_df,
    funder_info = funder_df
  )
}

#' Check for ORCIDs
#'
#' @inheritParams cr_compliance_overview
#' @family transform
#' @export
cr_has_orcid <- function(cr) {
  cr %>%
    select(.data$doi, .data$author) %>%
    mutate(has_orcid = sapply(
      purrr::map(.data$author, "ORCID"), is.character)
      ) %>%
    filter(.data$has_orcid == TRUE)
}

#' test if list is not empty
#' @noRd
empty_list <- function(x) {
  length(x) > 0
}
