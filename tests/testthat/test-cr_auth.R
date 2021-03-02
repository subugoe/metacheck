test_that("crossref metadata is enabled", {
  # could not capture with header response from rcrossref,
  # so result must be inspected manually in logs
  skip("Too noisy.")
  expect_success(
    rcrossref::cr_abstract("10.1109/TASC.2010.2088091", verbose = TRUE)
  )
})

test_that("metacheck declares polite user agent", {
  expect_true(is_valid_email(Sys.getenv("crossref_email")))
})
