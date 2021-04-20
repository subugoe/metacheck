test_that("paths exists", {
  expect_true(fs::dir_exists(path_report_template("en")))
  expect_true(fs::dir_exists(path_report_template("de")))
  expect_true(fs::file_exists(path_report_rmd("en")))
  expect_true(fs::file_exists(path_report_rmd("de")))
})

test_that("draft can be created from template", {
  expect_invisible(draft_report(file = withr::local_tempfile(), edit = FALSE))
})

test_that("parametrised report can be rendered", {
  expect_invisible(
    render_report(output_file = withr::local_tempfile(), quiet = TRUE)
  )
})
