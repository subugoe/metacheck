# shiny app ====

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
  Sys.sleep(5)
  expect_equal(
    app$findElement(".modal-title")$getText(),
    "You have successfully sent your DOIs"
  )
})
