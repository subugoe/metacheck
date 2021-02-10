test_that("metadata can be retrieved", {
  skip("Changes on crossref.")
  testthat::expect_snapshot_value(
    get_cr_md(dois = tu_dois()[1:10]),
    style = "json2"
  )
})
