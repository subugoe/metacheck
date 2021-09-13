test_that("email can be rendered", {
  # pretty bad test
  expect_s3_class(
    render_email(dois = c(dois_weird(), tu_dois()[1:3])),
    "blastula_message"
  )
})

test_that("email can be send", {
  skip_if_not_smtp_auth()
  skip_if_offline()
  expect_message(smtp_send_mc())
  expect_error({
    withr::local_envvar(.new = c("MAILJET_SMTP_PASSWORD" = "zap"))
    smtp_send_mc()
  })
})
