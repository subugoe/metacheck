test_that("Good example DOIs are all metacheckable", {
  expect_true(all(is_metacheckable(doi_examples$good)))
})
