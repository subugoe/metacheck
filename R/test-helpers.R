#' Throaway email recipient for testing
#' Recommended by https://stackoverflow.com/questions/1368163/is-there-a-standard-domain-for-testing-throwaway-email
#' @noRd
throwaway <- "whatever@mailinator.com"

#' used often b/c plain json doesn't cover complex objects
#' @noRd
expect_snapshot_value2 <- purrr::partial(
  testthat::expect_snapshot_value,
  style = "json2"
)
