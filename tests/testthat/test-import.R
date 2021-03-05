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

test_that("cr_works accepts only one doi (lonely)", {
  expect_error(lonely_cr_works(tu_dois()[2:3]))
  expect_type(lonely_cr_works(tu_dois()[2]), "list")
})

test_that("cr_works captures warnings (quiet)", {
  expect_match(
    quiet_cr_works("10.1000/foo")$warnings,
    regexp = "404"
  )
  expect_equal(
    quiet_cr_works(tu_dois()[2])$warnings,
    character()
  )
})

test_that("cr_works fails on bad output or warning (prickly)", {
  expect_error(prickly_cr_works("10.1000/foo"))
  expect_type(prickly_cr_works(tu_dois()[2]), "list")
})

test_that("cr_works retries on bad output (insistently)", {
  expect_error(
    suppressMessages(insistently_cr_works("10.1000/foo")),
    regexp = "attempts"
  )
})

test_that("cr_works uses cache (memoised)", {
  random_doi <- as.character(sample(dois_many(), size = 1))
  before <- system.time(memoised_cr_works(random_doi))["elapsed"]
  after <- system.time(memoised_cr_works(random_doi))["elapsed"]
  expect_lt(after, before / 10L)
})
