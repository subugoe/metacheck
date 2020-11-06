#' License overview
#'
#' @param cr crossref metadata
#'
#' @importFrom dplyr `%>%` group_by summarise mutate filter arrange desc n_distinct
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
#' @param cr crossref metadata
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
#' @param cr crossref metadata
#'
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr `%>%` group_by summarise mutate
#' @export
cr_md_ind <- function(cr, .group) {
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
#' @param cr crossref metadata
#' @importFrom dplyr `%>%` group_by summarise mutate filter arrange n_distinct bind_rows
#' @export
gather_ind_table <- function(cr) {
  # get indicators
  license_ind <- cr_license_ind(cr)
  tdm_ind <- cr_tdm_ind(cr)
  md_other <- cr_md_ind(cr)
  # bind together
  bind_rows(license_ind, tdm_ind, md_other) %>%
    mutate(all = n_distinct(cr$doi))%>%
    mutate(prop = articles / all * 100) %>%
    select(-all)
}
#' GT representation of compliance overview table
#'
#' @import gt
#' @param ind_table tibble compliance overview table
#'
#' @export
ind_table_to_gt <- function(ind_table) {
  gt::gt(ind_table, groupname_col = "ind_group") %>%
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
    fmt_number(
      columns = vars(prop),
      decimals = 0,
      pattern = "{x}%") %>%
    cols_align(align = "right",
               columns = vars(articles, prop)) %>%
    data_color(columns =vars(articles, prop),
               colors = scales::col_numeric(
                 # custom defined values - notice that order matters!
                 palette = rev(c("#39b185","#9ccb86","#e9e29c","#eeb479","#e88471","#cf597e")),
                 domain = NULL
               )) %>%
    tab_footnote(
      cells_body(
        columns = vars(type),
        rows = ind_group == "Others"
      ),
      footnote = "Metadata reporting can be subject to availability, e.g. an article was published without an abstract.") %>%
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
#' Reactable represenation of metadata indicators
#'
#' Inspired from <https://glin.github.io/reactable/articles/building-twitter-followers.html>
#'
#' @import reactable
#'
#' @param ind_table tibble compliance overview table
#' @param fill_col fill color for bar charts (hex code)
#'
#' @export
react_ind_table <- function(ind_table, fill_col = "#fc5185") {
  reactable::reactable(
    data = ind_table,
    columns = list(
      type = colDef(html = TRUE,
        name = "",
        style = list(fontFamily = "monospace", whiteSpace = "pre")
      ),
      articles = colDef(html = TRUE,
        name = "Articles",
        defaultSortOrder = "desc",
        format = colFormat(separators = TRUE),
        style = list(fontFamily = "monospace", whiteSpace = "pre")
      ),
      prop = colDef(html = TRUE,
        name = "Share",
        defaultSortOrder = "desc",
        # Render the bar charts using a custom cell render function
        cell = function(value) {
          value <- paste0(format(round(value * 100, 1), nsmall = 1), "%")
          # Fix width here to align single and double-digit percentages
          value <- format(value, width = 5, justify = "right")
          react_bar_chart(value, width = value, fill = fill_col, background = "#e1e1e1")
        },
        align = "left",
        style = list(fontFamily = "monospace", whiteSpace = "pre")
      )
    ),
    compact = FALSE
  )
}

#' React bar chart helper
#'
#' From <https://glin.github.io/reactable/articles/building-twitter-followers.html>
#'
#' @importFrom htmltools div
#'
#' @noRd
react_bar_chart <- function(label, width = "100%", height = "14px", fill = "#00bfc4", background = NULL) {
  bar <- htmltools::div(style = list(background = fill, width = width, height = height))
  chart <- htmltools::div(style = list(flexGrow = 1, marginLeft = "6px", background = background), bar)
  htmltools::div(style = list(display = "flex", alignItems = "center"), label, chart)
}

