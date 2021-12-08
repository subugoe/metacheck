test_that("individual results are assembled", {
  expect_snapshot(names(create_ss()))
})

test_that("spreadsheet is written to file", {
  checkmate::expect_file_exists(write_xlsx_mc(create_ss()))
})

test_that("individual results can be created and attached", {
  expect_true(length(create_and_attach_ss()$attachments) == 1L)
})
