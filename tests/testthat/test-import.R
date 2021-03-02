test_that("Acceptable DOIs are filtered", {
  x <- biblids::as_doi(c(
    "10.1000/1",
    NA, # is NA
    "doi:10.1000/1", # not unique,
    "10.1000/3",
    "10.1000/4",
    "10.1000/5" # this is above limit of 4
  ))
  expect_snapshot_value(tabulate_metacheckable(x, limit = 3), style = "json2")
  expect_snapshot_value(is_metacheckable(x, limits = 3), style = "json2")
})
