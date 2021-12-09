# shiny app ====

# multisession futures need locally installed metacheck
# but not inside R cmd check where pkg is already installed
if (!is_rcmd_check()) local_mc()

test_that("shiny app works", {
  app <- shinytest::ShinyDriver$new(mcControlsApp())
  app$click("test-dois-fill_ex")
  # takes some time proably b/c or debouncing
  Sys.sleep(2)
  app$click("test-dois-submit")
  app$setInputs(`test-send-recipient` = throwaway)
  app$setInputs(`test-send-gdpr_consent` = TRUE)
  app$click("test-send-send")
  # sending email is done async, so we need to wait
  Sys.sleep(150)
  expect_equal(
    app$findElement(".shiny-notification-content-text")$getText(),
    "Your report is in your email inbox. Remember to check your SPAM folder."
  )
})
