test_that("Crossref metadata can be read in", {
  dois <- tu_dois()[2:5]
  res <- cr_works2(dois)
  expect_equal(nrow(res), length(dois))
  # testthat does not seem to know about vctrs equality
  # https://github.com/r-lib/testthat/issues/1349
  expect_true(all(biblids::as_doi(res$doi) == biblids::as_doi(dois)))
})
