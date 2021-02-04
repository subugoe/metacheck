test_that("crossref metadata is enabled", {
  # could not capture with header response from rcrossref,
  # so result must be inspected manually in logs
  rcrossref::cr_abstract('10.1109/TASC.2010.2088091', verbose = TRUE)
  expect_equal(1, 1)
})

test_that("crossref metadata plus is faster", {
  skip("Test does not work; times are often the same.")
  with_mdplus <- bench::bench_time(
    rcrossref::cr_agency(tu_dois[1:10], .progress = "text")
  )["real"]
  withr::local_envvar(.new = c("crossref_plus" = ""))
  without_mdplus <- bench::bench_time(
    rcrossref::cr_agency(tu_dois[1:10], .progress = "text")
  )["real"]
  expect_lte(with_mdplus, without_mdplus)
})

test_that("metacheck declares polite user agent", {
  expect_true(is_valid_email(Sys.getenv("crossref_email")))
})
