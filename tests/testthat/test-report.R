test_that("report templates exist in all languages", {
  purrr::map_chr(
    .x = mc_langs,
    .f = function(x) expect_true(fs::dir_exists(path_report_template(!!x)))
  )
  purrr::map_chr(
    .x = mc_langs,
    .f = function(x) expect_true(fs::file_exists(path_report_rmd(!!x)))
  )
})

test_that("draft can be created from template", {
  expect_invisible(draft_report(file = withr::local_tempfile(), edit = FALSE))
})

test_that("parametrised report can be rendered", {
  expect_invisible(
    render_report(output_file = withr::local_tempfile(), quiet = TRUE)
  )
})
