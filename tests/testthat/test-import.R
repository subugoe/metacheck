# wrapped cr api calls ====

dois <- tu_dois()[2:5]

test_that("Crossref metadata can be read in", {  
  # testthat does not seem to know about vctrs equality
  # https://github.com/r-lib/testthat/issues/1349
  expect_true(
    all(biblids::as_doi(cr_works2(dois)$doi) == biblids::as_doi(dois))
  )
})

test_that("cr_works2 is length-stable", {
  expect_equal(nrow(cr_works2(dois)), length(dois))
  expect_equal(nrow(cr_works2(dois[1])), 1)
  skip("Length instability in columns cannot be repaired by wrapper.")
  # blocked by https://github.com/subugoe/metacheck/issues/183
  expect_equal(ncol(cr_works2(dois)), ncol(cr_works2(dois[1])))
})

test_that("Bad DOIs throw error", {
  skip("Not implemented")
  expect_equal(1, 1)
})
