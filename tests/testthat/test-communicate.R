# shiny app ====

test_that("shiny app works", {
  app <- shinytest::ShinyDriver$new(mcControlsApp())
  app$click("test-dois-fill_ex")
  app$click("test-dois-submit")
  app$setInputs(`test-send-recipient` = throwaway)
  app$setInputs(`test-send-gdpr_consent` = TRUE)
  app$click("test-send-send")
  # sending email is done async, so we need to wait
  Sys.sleep(5)
  expect_equal(
    app$findElements(".modal-title")[[1]]$getText(),
    "You have succesfully send your DOIs"
  )
})
