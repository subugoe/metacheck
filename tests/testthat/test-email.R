test_that("complete email can be composed", {
  # pretty bad test
  expect_s3_class(
    mc_compose_email(), "blastula_message"
  )
})

test_that("outer email can be composed", {
  # pretty bad test
  expect_s3_class(mc_compose_email_outer(), "blastula_message")
})

test_that("email can be rendered", {
  # pretty bad test
  expect_s3_class(mc_render_email(), "blastula_message")
})

test_that("email is smaller than 102KB to meet google limit", {
  # emails bigger than 102kb are clipped on gmail.com
  email_source <- mc_compose_email(dois = doi_examples$good)$html_html
  expect_true(lobstr::obj_size(email_source) / 1000 < 102)
})

# multisession futures need locally installed metacheck
# but not inside R cmd check where pkg is already installed
if (!is_rcmd_check()) local_mc()

test_that("email can be send", {
  skip_if_not_smtp_auth()
  skip_if_offline()
  expect_message(smtp_send_mc())
  expect_error({
    withr::local_envvar(.new = c("MAILJET_SMTP_PASSWORD" = "zap"))
    smtp_send_mc()
  })
})
