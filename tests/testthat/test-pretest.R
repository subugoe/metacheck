# This need not cover any abnormalities already covered in biblids

test_that("Acceptable DOIs are filtered", {
  expect_snapshot_value2(tabulate_metacheckable(dois_weird(), limit = 3))
  expect_snapshot_value2(is_metacheckable(dois_weird(), limit = 3))
})

test_that("Acceptable DOIs can be asserted", {
  expect_error(assert_metacheckable(dois_weird()))
  expect_invisible(
    assert_metacheckable(dois_weird()[is_metacheckable(dois_weird())])
  )
})

test_that("DOI acceptability is reported", {
  expect_snapshot_value2(report_metacheckable(dois_weird()))
})

# custom predicates ====

test_that("DOI RA is identified", {
  expect_equal(
    is_doi_from_ra_cr(c("10.1000/1", "10.3389/fbioe.2020.00209")),
    c(FALSE, TRUE)
  )
  # scalar test necessary b/c rcrossref is not type stable
  expect_equal(
    is_doi_from_ra_cr("10.3389/fbioe.2020.00209"),
    TRUE
  )
})
