test_dois <- tu_dois()[1:5]
req <- get_cr_md(test_dois)
out <- cr_compliance_overview(req)

# indexing status
test_that("indexing status is reported", {
  # all found
  expect_snapshot_output(indexing_status(dois = test_dois, .md = out))
  # not all found, print non-indexed doi
  expect_snapshot_output(indexing_status(dois = c("bbl", test_dois), .md = out))
})

# metrics overview
test_that("metrics_overview works", {
  a <- metrics_overview(out, .gt = FALSE)

  # dimensions and type
  expect_equal(ncol(a), 3)
  expect_equal(nrow(a), 7)
  expect_s3_class(a, "data.frame")

  expect_error(metrics_overview())
  expect_error(metrics_overview("kdkd"))
})

test_that("metrics_overview is reported", {
  expect_is(metrics_overview(out), "gt_tbl")
})

# cc compliance

test_that("cc_metrics works", {
  a <- cc_metrics(out$cc_license_check)

  # dimensions and type
  expect_equal(ncol(a), 3)
  expect_s3_class(a, "data.frame")

  expect_error(cc_metrics())
  expect_error(cc_metrics("kdkd"))
})

# test_that("cc_metrics are reported", {
#   expect_is(cc_metrics(out), "gt_tbl")
# })

test_that("cc_compliance_metrics works", {
  a <- cc_compliance_metrics(out$cc_license_check)

  # dimensions and type
  expect_equal(ncol(a), 3)
  expect_s3_class(a, "data.frame")

  expect_error(cc_compliance_metrics())
  expect_error(cc_compliance_metrics("kdkd"))
})

#test_that("cc_compliance_metrics are reported", {
#  expect_is(cc_metrics(out$cc_license_check), "gt_tbl")
#})

## tdm compliance

test_that("tdm works", {
  a <- tdm_metrics(out, .gt = FALSE)

  # dimensions and type
  expect_equal(ncol(a), 3)
  expect_s3_class(a, "data.frame")

  expect_error(metrics_overview())
  expect_error(metrics_overview("kdkd"))
})

test_that("tdm are reported", {
  expect_is(metrics_overview(out), "gt_tbl")
})

## funder compliance

test_that("tdm works", {
  a <- funder_metrics(out, .gt = FALSE)

  # dimensions and type
  expect_equal(ncol(a), 3)
  expect_s3_class(a, "data.frame")

  expect_error(metrics_overview())
  expect_error(metrics_overview("kdkd"))
})

test_that("tdm are reported", {
  expect_is(metrics_overview(out), "gt_tbl")
})

