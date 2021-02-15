#' CC license variants metrics overview
#'
#' Presents normalised CC licence variants like BY (absolute and relative)
#'
#' @inheritParams metrics_overview
#'
#' @importFrom dplyr count mutate rename
#'
#' @export
cc_metrics <- function(.md = NULL, .gt = TRUE,  .color = "#F3A9BB") {
  if(is.null(.md) || !"cc_license_check" %in% names(.md))
    stop("No CC compliance data provided, get data using cr_compliance_overview()")
  else
    out <- .md$cc_license_check %>%
      dplyr::count(cc_norm, name = "value") %>%
      dplyr::mutate(prop = value /sum(value) * 100) %>%
      dplyr::rename(name = cc_norm)
  if(.gt == FALSE)
    out
  else
    ind_table_to_gt(out, prop = prop, .color = .color)
}

#' CC compliance metrics overview
#'
#' Presents the result of the CC compliance check (absolute and relative)
#'
#' @seealso [license_check()]
#'
#' @inheritParams metrics_overview
#'
#' @importFrom dplyr count mutate rename
#'
#' @export
cc_compliance_metrics <- function(.md = NULL, .gt = TRUE,  .color = "#A0A5A9") {
  if(is.null(.md) || !"cc_license_check" %in% names(.md))
    stop("No compliance overview data provided, get data using cr_compliance_overview()")
  else
    out <- .md$cc_license_check %>%
      dplyr::count(check_result, name = "value") %>%
      dplyr::mutate(prop = value /sum(value) * 100) %>%
      dplyr::rename(name = check_result)
  if(.gt == FALSE)
    out
  else
    ind_table_to_gt(out, prop = prop, .color = .color)
}
