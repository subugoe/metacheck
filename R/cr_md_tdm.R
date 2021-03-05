#' Get text-mining links from Crossref metadata
#'
#' Unnest TDM information for version-of-records from Crossref metadata
#'
#' @param cr crossref metadata using [get_cr_md()]
#' @family transform
#' @export
cr_tdm_df <- function(cr) {
  empty_tdm(cr) %>%
      dplyr::select(
        .data$doi,
        container_title = .data$container.title,
        .data$publisher,
        .data$issued,
        .data$issued_year,
        .data$link
      ) %>%
      tidyr::unnest(cols = "link", keep_empty = TRUE) %>%
      dplyr::mutate(
        is_tdm_compliant = ifelse(
          .data$content.version == "vor" &
            .data$intended.application == "text-mining",
          TRUE,
          FALSE
        )
      )
}

#' dirty hack to prevent for missing TDM json nodes
#' https://github.com/subugoe/metacheck/issues/183
#'
#' @noRd
empty_tdm <- function(cr) {
  if (!"link" %in% colnames(cr)) {
    link <- list(tibble::tibble(
      URL = as.character(NA),
      content.type = as.character(NA),
      content.version = as.character(NA),
      intended.application = as.character(NA)
    ))
    out <- dplyr::mutate(cr, link = link)
  } else {
    out <- cr
  }
  out
}
