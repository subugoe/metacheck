test_that("email can be rendered", {
  # pretty bad test
  expect_s3_class(
    render_email(dois = c(dois_weird(), tu_dois()[1:3])),
    "blastula_message"
  )
})

test_that("email can be send", {
  skip_if_not_smtp_auth()
  # recommended by https://stackoverflow.com/questions/1368163/is-there-a-standard-domain-for-testing-throwaway-email
  throwaway <- "whatever@mailinator.com"
  expect_message({
    smtp_send_metacheck(
      email = blastula::prepare_test_message(),
      to = throwaway,
      subject = "Test email",
      cc = NULL,
    )
  })
  expect_error({
    withr::local_envvar(.new = c("MAILJET_SMTP_PASSWORD" = "zap"))
    smtp_send_metacheck(
      email = blastula::prepare_test_message(),
      to = throwaway,
      subject = "Bad test email",
      cc = NULL
    )
  })
})
