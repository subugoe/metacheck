#' Diagnose Creative Commons Licensing
#' @family transform
#' @examples
#' # obtain metadata from Crossref API
#' req <- get_cr_md(doi_examples$good)
#'
#' # check article-level compliance
#' out <- cr_compliance_overview(req)
#' @name cc
NULL

#' @describeIn cc Presents normalised CC licence variants.
#' For example, `BY` (absolute and relative).
#'
#' @param cc_license_check tibble, result from [license_check()]
#' @export
#' @examples
#' # obtain CC variants metrics
#' cc_metrics(out$cc_license_check)
cc_metrics <- function(cc_license_check = NULL) {
  is_cr_license_df(cc_license_check)
  cc_license_check %>%
    dplyr::count(indicator = .data$cc_norm, name = "value") %>%
    dplyr::mutate(prop = .data$value / sum(.data$value) * 100)
}

#' @describeIn cc Presents the result of the CC compliance check.
#' Absolute and relative normalised CC licence variants.
#'
#' @seealso [license_check()]
#' @export
#' @examples
#' # Obtain cc compliance check resutls metrics
#' cc_compliance_metrics(out$cc_license_check)
#' @keywords internal
cc_compliance_metrics <- function(cc_license_check = NULL) {
  is_cr_license_df(cc_license_check)
  cc_license_check %>%
    dplyr::count(indicator = .data$check_result, name = "value") %>%
    dplyr::mutate(prop = .data$value / sum(.data$value) * 100)
}

#' Check if CC compliance data is provided
#' @noRd
is_cr_license_df <- function(x) {
  assertthat::assert_that(x %has_name% cc_license_df_skeleton(),
                          msg = "No CC compliance data provided, get data using license_check() or cr_compliance_overview()")
}
