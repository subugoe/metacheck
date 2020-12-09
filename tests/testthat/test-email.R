test_that("email can be rendered", {
  # pretty bad test
  checkmate::expect_list(render_email(dois = tu_dois()[0:10]))
})
