test_that("long docs / translations are found", {
  checkmate::expect_file_exists(mc_long_docs("disclaimer_fe.md"))
  checkmate::expect_string(mc_long_docs_string("disclaimer_fe.md"))
})
