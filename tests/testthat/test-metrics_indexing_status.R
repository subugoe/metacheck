test_that("indexing status is reported", {
  test_dois <- tu_dois()[1:5]
  req <- get_cr_md(test_dois)
  out <- cr_compliance_overview(req)
  # all found
  expect_snapshot_output(indexing_status(dois = test_dois, .md = out))
  # not all found, print non-indexed doi
  expect_snapshot_output(indexing_status(dois = c("bbl", test_dois), .md = out))
})
