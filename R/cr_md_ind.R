#' GT representation of compliance overview table
#'
#' @param ind_table tibble compliance metrics overview
#' @param .color table styling
#' @family visualize
#' @export
ind_table_to_gt <- function(ind_table, .color = NULL) {
  is_ind_table(ind_table)
  ind_table %>%
    dplyr::mutate(
      prop_bar = purrr::map(.data$prop, ~ bar_chart(value = .x, .color = .color))
    ) %>%
    gt::gt() %>%
    gt::cols_label(
      indicator = "",
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
      vars(indicator) ~ gt::px(150)
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
               columns = vars(indicator, prop_bar)) %>%
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
bar_chart <- function(value, .color = "red"){
  glue::glue(
    "<span style=\"display: inline-block; direction: ltr; border-radius: 4px; ",
    "padding-right: 2px; background-color: {.color}; color: {.color}; ",
    "width: {value}%\"> &nbsp; </span>"
  ) %>%
    as.character() %>%
    gt::html()
}

#' Follows metrics skeleton
#' @noRd
is_ind_table <- function(x) {
  assertthat::assert_that(x %has_name% metrics_skeleton(),
                          msg = "Compliance metrics must be a tibble with three columns: indicator, value, prop.")
}
