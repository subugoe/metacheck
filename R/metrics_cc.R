#' CC license variants metrics overview
#'
#' Presents normalised CC licence variants like BY (absolute and relative)
#'
#' @param cc_license_check tibble, result from [license_check()]
#' @export
cc_metrics <- function(cc_license_check = NULL) {
  #, .gt = TRUE,  .color = "#F3A9BB") {
  if (is.null(cc_license_check)) {
    rlang::abort(
      "No CC compliance data provided, get data using license_check()"
    )
  }
  cc_license_check %>%
    dplyr::count(cc_norm, name = "value") %>%
    dplyr::mutate(prop = value / sum(value) * 100)
}

#' CC compliance metrics overview
#'
#' Presents the result of the CC compliance check (absolute and relative)
#'
#' @seealso [license_check()]
#'
#' @inheritParams cc_metrics
#'
#' @export
cc_compliance_metrics <- function(cc_license_check = NULL) {
  #.gt = TRUE,  .color = "#A0A5A9") {
  if (is.null(cc_license_check)) {
    rlang::abort("No compliance overview data provided, get data using license_check()")
  }
  cc_license_check %>%
    dplyr::count(indicator = check_result, name = "value") %>%
    dplyr::mutate(prop = value / sum(value) * 100)
}
