test_that("metadata can be retrieved", {
  skip("Changes on crossref.")
  testthat::expect_snapshot_value(
    get_cr_md(dois = tu_dois()[1:10]),
    style = "json2"
  )
})

test_that("Unsuccesful Crossref API metadata fetch",
          {
            testthat::expect_null(get_cr_md(dois = "ldld"))
            testthat::expect_null(get_cr_md(dois = c("dkdkd", "kdkdkdk")))
          })
