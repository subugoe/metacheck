# wrapped cr api calls ====

skip_if_offline()
dois <- doi_examples$good[2:5]

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

test_that("cr_works2 throws error on bad DOIs", {
  expect_error(suppressMessages(cr_works2(c(dois[1], "10.1000/foo"))))
})

test_that("cr_works accepts only one doi (lonely)", {
  expect_error(lonely_cr_works(as.character(dois[2:3])))
  expect_type(lonely_cr_works(as.character(dois[2])), "list")
})

test_that("cr_works captures warnings (quiet)", {
  expect_match(
    quiet_cr_works("10.1000/foo")$warnings,
    regexp = "404"
  )
  expect_equal(
    quiet_cr_works(as.character(dois[2]))$warnings,
    character()
  )
})

test_that("cr_works fails on bad output or warning (prickly)", {
  expect_error(prickly_cr_works("10.1000/foo"))
  expect_type(prickly_cr_works(as.character(dois[2])), "list")
})

test_that("cr_works retries on bad output (insistently)", {
  expect_error(
    suppressMessages(insistently_cr_works("10.1000/foo")),
    regexp = "attempts"
  )
})

test_that("cr_works uses cache (memoised)", {
  skip("Test is not deterministic (#291)")
  # see https://github.com/subugoe/metacheck/issues/291
  random_doi <- as.character(sample(doi_examples$many, size = 1))
  before <- system.time(memoised_cr_works(random_doi))["elapsed"]
  after <- system.time(memoised_cr_works(random_doi))["elapsed"]
  expect_lt(after, before / 10L)
})

test_that("cr_works_field can find fields", {
  expect_true(
    biblids::as_doi(
      cr_works_field(as.character(dois[1]), "doi")
    ) == biblids::as_doi(dois[1])
  )
})

test_that("cr_works_field defaults to NA for errors", {
  expect_equal(
    possibly_cr_works_field("10.1000/foo", "doi"),
    NA
  )
})

test_that("many cr_works_fields can be retrieved", {
  expect_equal(
    looped_possibly_cr_works_field(c("10.1000/foo", as.character(dois[1])), "doi"),
    c(NA, as.character(dois[1]))
  )
})
