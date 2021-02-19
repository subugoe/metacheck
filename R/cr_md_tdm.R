#' Get text-mining links from Crossref metadata
#'
#' Unnest TDM information for version-of-records from Crossref metadata
#'
#' @param cr crossref metadata using [get_cr_md()]
#' @family transform
#' @export
cr_tdm_df <- function(cr) {
  if ("link" %in% colnames(cr)) {
    out <- cr %>%
      select(
        .data$doi,
        container_title = .data$container.title,
        .data$publisher,
        .data$issued,
        .data$issued_year,
        .data$link
      ) %>%
      unnest(cols = "link", keep_empty = TRUE) %>%
      mutate(
        is_tdm_compliant = ifelse(
          .data$content.version == "vor" &
            .data$intended.application == "text-mining",
          TRUE,
          FALSE
        )
      )
  } else {
    out <- NULL
  }
  out
}
