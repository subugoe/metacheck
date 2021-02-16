test_that("metadata can be retrieved", {
  skip("Changes on crossref.")
  testthat::expect_snapshot_value(
    get_cr_md(dois = tu_dois()[1:10]),
    style = "json2"
  )
})

test_that("DOIs not on CR are identified", {
  expect_true(has_cr_md("10.5194/wes-2019-70"))
  expect_equal(has_cr_md("10.1000/foo"), FALSE)
})
