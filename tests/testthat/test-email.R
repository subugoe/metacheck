test_that("email can be rendered", {
  # pretty bad test
  checkmate::expect_list(render_email(dois = tu_dois()[0:10]))
})

test_that("email can be send", {
  skip_if(
    Sys.getenv("MAILJET_SMTP_PASSWORD") == "",
    message = "Mailjet credentials not available."
  )
  testthat::skip_if_not(
    Sys.getenv("GITHUB_REF" == "refs/heads/main"),
    message = "Testing email only on main."
  )
  send_email(
    to = "held@sub.uni-goettingen.de",
    email = blastula::prepare_test_message(),
    cc = NULL
  )
  send_email(
    to = "held@sub.uni-goettingen.de",
    email = render_email(dois = tu_dois()[0:10]),
    cc = NULL
  )
})
