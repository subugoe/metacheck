#' License overview
#'
#' @param cr
#'
#' @importFrom dplyr `%>%` group_by summarise mutate filter arrange
#'
#' @export
cr_license_ind <- function(cr) {
  license_normalise(cr) %>%
    group_by(type = license) %>%
    summarise(articles = n_distinct(doi)) %>%
    arrange(desc(articles)) %>%
    mutate(ind_group = "CC licenses")
}
#' TDM overview
#'
#' @param cr
#'
#' @importFrom dplyr `%>%` group_by summarise mutate filter
#' @importFrom tidyr unnest
#' @export
cr_tdm_ind <- function(cr) {
  cr %>%
    select(link, doi) %>%
    unnest(cols = "link") %>%
    filter(content.version == "vor", intended.application == "text-mining") %>%
    group_by(type = content.type) %>%
    summarise(articles = n_distinct(doi)) %>%
    mutate(ind_group = "TDM")
}
#' Other types of relevant metadata
#'
#' @param cr
#'
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr `%>%` group_by summarise mutate
#' @export
cr_md_ind <- function(cr, .group = NULL) {
  cr %>%
    group_by({{ .group }}) %>%
    summarise(
      has_abstract = sum(!is.na(abstract)), # abstract
      has_open_ref = sum(sapply(reference, is.data.frame)),
      has_funder = sum(sapply(funder, is.data.frame)), # open references
      has_orcid = sum(sapply(purrr::map(author, "ORCID"), is.character)) # author info
    ) %>%
    tidyr::pivot_longer(1:4, names_to = "type", values_to = "articles") %>%
    mutate(ind_group = "Others")
}
#' Create compliance overview table
#'
#' @param cr
#'
#' @export
gather_ind_table <- function(cr) {
  # get indicators
  license_ind <- cr_license_ind(cr)
  tdm_ind <- cr_tdm_ind(cr)
  md_other <- cr_md_ind(cr)
  # bind together
  bind_rows(license_ind, tdm_ind, md_other) %>%
    mutate(all = n_distinct(cr$doi))%>%
    mutate(prop = articles / all) %>%
    select(-all)
}
#' GT representation of compliance overview table
#'
#' @param ind_table tibble compliance overview table
#'
ind_table_to_gt <- function(ind_table) {
  gt::gt(groupname_col = "ind_group") %>%
    gt::cols_label(
      type = "",
      articles = "Articles",
      prop = "Share") %>%
    tab_stubhead("type") %>%
    tab_style(
      style = cell_text(color = "black", weight = "bold"),
      locations = list(
        cells_row_groups())
    ) %>%
    tab_style(
      style = cell_text(color = "black", weight = "bold"),
      locations = list(
        cells_row_groups(),
        cells_column_labels(everything())
      )
    ) %>%
    cols_width(
      vars(type) ~ px(125)
    ) %>%
    fmt_percent(
      columns = vars(prop),
      decimals = 0) %>%
    cols_align(align = "right",
               columns = vars(articles, prop)) %>%
    data_color(columns =vars(articles, prop),
               colors = scales::col_numeric(
                 # custom defined values - notice that order matters!
                 palette = c("#fcde9c","#faa476","#f0746e","#e34f6f","#dc3977","#b9257a","#7c1d6f"),
                 domain = NULL
               )) %>%
    tab_options(
      row_group.border.top.width = px(3),
      row_group.border.top.color = "black",
      row_group.border.bottom.color = "black",
      table_body.hlines.color = "white",
      table.border.top.color = "white",
      table.border.top.width = px(3),
      table.border.bottom.color = "white",
      table.border.bottom.width = px(3),
      column_labels.border.bottom.color = "black",
      column_labels.border.bottom.width = px(2)
    ) %>%
    tab_source_note(md("**Table**: Overview: Crossref metadata compliance check"))
}
