test_that("email can be rendered", {
  checkmate::expect_list(render_email())
})
