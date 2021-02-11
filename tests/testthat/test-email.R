test_that("email can be rendered", {
  # pretty bad test
  checkmate::expect_list(render_email(dois = tu_dois()[0:10]))
})

test_that("email can be send", {
  skip_if_not_smtp_auth()
  expect_message({
    smtp_send_metacheck(
      email = blastula::prepare_test_message(),
      to = "held@sub.uni-goettingen.de",
      subject = "Test email",
      cc = NULL,
    )
  })
  expect_error({
    withr::local_envvar(.new = c("MAILJET_SMTP_PASSWORD" = "zap"))
    smtp_send_metacheck(
      email = blastula::prepare_test_message(),
      to = "held@sub.uni-goettingen.de",
      subject = "Bad test email",
      cc = NULL
    )
  })
})
