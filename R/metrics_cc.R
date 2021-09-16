#' CC license variants metrics overview
#'
#' Presents normalised CC licence variants like BY (absolute and relative)
#'
#' @param cc_license_check tibble, result from [license_check()]
#'
#' @export
#'
#' @examples \dontrun{
#' my_dois <- c("10.5194/wes-2019-70", "10.1038/s41598-020-57429-5",
#'   "10.3389/fmech.2019.00073", "10.1038/s41598-020-62245-y",
#'   "10.1109/JLT.2019.2961931")
#'
#' # Workflow:
#' # First, obtain metadata from Crossref API
#' req <- get_cr_md(my_dois)
#'
#' # Then, check article-level compliance
#' out <- cr_compliance_overview(req)
#'
#' # Obtain CC variants metrics
#' cc_metrics(out$cc_license_check)
#' }
#' @keywords internal
cc_metrics <- function(cc_license_check = NULL) {
  is_cr_license_df(cc_license_check)
  cc_license_check %>%
    dplyr::count(indicator = .data$cc_norm, name = "value") %>%
    dplyr::mutate(prop = .data$value / sum(.data$value) * 100)
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
#'
#' @examples \dontrun{
#' my_dois <- c("10.5194/wes-2019-70", "10.1038/s41598-020-57429-5",
#'   "10.3389/fmech.2019.00073", "10.1038/s41598-020-62245-y",
#'   "10.1109/JLT.2019.2961931")
#'
#' # Workflow:
#' # First, obtain metadata from Crossref API
#' req <- get_cr_md(my_dois)
#'
#' # Then, check article-level compliance
#  out <- cr_compliance_overview(req)
#'
#' # Obtain CC compliance check resutls metrics
#' cc_compliance_metrics(out$cc_license_check)
#' }
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
