x <- biblids::as_doi(c(
  "10.1000/1",
  NA, # is NA
  "doi:10.1000/1", # not unique,
  "10.1000/3",
  "10.1000/4",
  "10.1000/5" # this is above limit of 4
))

test_that("Acceptable DOIs are filtered", {
  dframe <- tabulate_metacheckable(x, limit = 3)
  expect_snapshot_value(dframe, style = "json2")
  expect_snapshot_value(is_metacheckable(x, limits = 3), style = "json2")
})

test_that("Acceptable DOIs can be asserted", {
  expect_error(assert_metacheckable(x))
  expect_invisible(assert_metacheckable(x[is_metacheckable(x)]))
})

test_that("DOI eligiblity is reported", {
  dframe <- tabulate_metacheckable(x, limit = 3)
  expect_snapshot_value(report_metacheckable(dframe), style = "json2")
})
