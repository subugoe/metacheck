#' License overview
#'
#' @param cr crossref metadata
#' @family transform
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
#' @family transform
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
#' @param .group group by variable, like publisher
#' @family transform
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
#' @family visualize
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
    select(-all) %>%
    mutate(prop_bar = purrr::map(prop, ~bar_chart(value = .x, color = "#00bfc4")))
}

#' GT representation of compliance overview table
#'
#' @param ind_table tibble compliance overview table
#' @family visualize
#' @export
ind_table_to_gt <- function(ind_table) {
  gt::gt(ind_table) %>%
    gt::cols_label(
      name = "",
      value = "Artikel",
      prop = "Anteil",
      prop_bar = "") %>%
    gt::tab_style(
      style = gt::cell_text(color = "black", weight = "bold"),
      locations = list(
        gt::cells_column_labels(everything())
      )
    ) %>%
    gt::cols_width(
      vars(name) ~ gt::px(150)
    ) %>%
    gt::cols_width(
      vars(prop_bar) ~ gt::px(100)
    ) %>%
    gt::fmt_number(
      columns = vars(prop),
      decimals = 0,
      pattern = "{x}%") %>%
    gt::cols_align(align = "right",
               columns = vars(value, prop)) %>%
    gt::cols_align(align = "left",
               columns = vars(prop_bar)) %>%
    gt::tab_options(
      row_group.border.top.width = gt::px(3),
      row_group.border.top.color = "black",
      row_group.border.bottom.color = "black",
      table_body.hlines.color = "white",
      table.border.top.color = "white",
      table.border.top.width = gt::px(3),
      table.border.bottom.color = "white",
      table.border.bottom.width = gt::px(3),
      column_labels.border.bottom.color = "black",
      column_labels.border.bottom.width = gt::px(2)
    )
}

#' Embed HTML Bar Charts in gt
#'
#' <https://themockup.blog/posts/2020-10-31-embedding-custom-features-in-gt-tables/>
#'
#' @noRd
bar_chart <- function(value, color = "red"){
  glue::glue("<span style=\"display: inline-block; direction: ltr; border-radius: 4px; padding-right: 2px; background-color: {color}; color: {color}; width: {value}%\"> &nbsp; </span>") %>%
    as.character() %>%
    gt::html()
}

#' Reactable represenation of metadata indicators
#' @param ind_table tibble compliance overview table
#' @param fill_col fill color for bar charts (hex code)
#' @family visualize
#' @export
react_ind_table <- function(ind_table, fill_col = "#fc5185") {
  # Inspired from <https://glin.github.io/reactable/articles/building-twitter-followers.html>
  reactable::reactable(
    data = ind_table,
    columns = list(
      type = reactable::colDef(html = TRUE,
        name = "",
        style = list(fontFamily = "monospace", whiteSpace = "pre")
      ),
      articles = colDef(html = TRUE,
        name = "Articles",
        defaultSortOrder = "desc",
        format = reactable::colFormat(separators = TRUE),
        style = list(fontFamily = "monospace", whiteSpace = "pre")
      ),
      prop = reactable::colDef(html = TRUE,
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
#' @noRd
react_bar_chart <- function(label, width = "100%", height = "14px", fill = "#00bfc4", background = NULL) {
  bar <- htmltools::div(style = list(background = fill, width = width, height = height))
  chart <- htmltools::div(style = list(flexGrow = 1, marginLeft = "6px", background = background), bar)
  htmltools::div(style = list(display = "flex", alignItems = "center"), label, chart)
}
