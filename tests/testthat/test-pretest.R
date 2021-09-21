# This need not cover any abnormalities already covered in biblids
skip_if_offline()

test_that("Acceptable DOIs are filtered", {
  expect_snapshot_value2(tabulate_metacheckable(doi_examples$weird, limit = 3))
  expect_snapshot_value2(is_metacheckable(doi_examples$weird, limit = 3))
})

test_that("Acceptable DOIs can be asserted", {
  expect_error(assert_metacheckable(doi_examples$weird))
  expect_invisible(
    assert_metacheckable(doi_examples$weird[is_metacheckable(doi_examples$weird)])
  )
})

test_that("DOI acceptability is reported", {
  expect_snapshot_value2(report_metacheckable(doi_examples$weird))
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

test_that("Missing DOI md on cr are caught", {
  expect_equal(
    is_doi_cr_md(c("10.1000/1", "10.3389/fbioe.2020.00209")),
    c(FALSE, TRUE)
  )
  expect_equal(
    is_doi_cr_md(c("10.1000/1", "10.1000/2")),
    c(FALSE, FALSE)
  )
})

test_that("Type on cr is caught", {
  expect_equal(
    is_doi_cr_type(
      c("10.3389/frobt.2020.00074", "10.3389/fbioe.2020.00209"),
      "journal-article"
    ),
    c(TRUE, TRUE)
  )
})
