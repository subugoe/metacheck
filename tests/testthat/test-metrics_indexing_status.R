test_dois <- tu_dois()[2:6]
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
  a <- metrics_overview(out$cr_overview)

  # dimensions and type
  expect_equal(ncol(a), 3)
  expect_equal(nrow(a), 7)
  expect_s3_class(a, "data.frame")

  expect_error(metrics_overview())
  expect_error(metrics_overview("kdkd"))
  expect_error(select(metrics_overview(out$cr_overview), -has_orcid))

})

test_that("metrics_overview is reported", {
  expect_s3_class(metrics_overview(out$cr_overview) %>% ind_table_to_gt(.color = "red"), "gt_tbl")
})

# cc compliance

test_that("cc_metrics works", {
  a <- cc_metrics(out$cc_license_check)

  # dimensions and type
  expect_equal(ncol(a), 3)
  expect_s3_class(a, "data.frame")

  expect_error(cc_metrics())
  expect_error(cc_metrics("kdkd"))
  expect_error(select(cc_metrics(out$cc_license_check), -cc_norm))

})

 test_that("cc_metrics are reported", {
   expect_s3_class(cc_metrics(out$cc_license_check) %>% ind_table_to_gt(.color = "red"), "gt_tbl")
 })

test_that("cc_compliance_metrics works", {
  a <- cc_compliance_metrics(out$cc_license_check)

  # dimensions and type
  expect_equal(ncol(a), 3)
  expect_s3_class(a, "data.frame")

  expect_error(cc_compliance_metrics())
  expect_error(cc_compliance_metrics("kdkd"))
  expect_error(select(cc_compliance_metrics(out$cc_license_check), -check_result))
})

test_that("cc_compliance_metrics are reported", {
  expect_s3_class(cc_metrics(out$cc_license_check) %>% ind_table_to_gt(.color = "red"), "gt_tbl")
})

## tdm compliance

test_that("tdm works", {
  a <- tdm_metrics(out$tdm)

  # dimensions and type
  expect_equal(ncol(a), 3)
  expect_s3_class(a, "data.frame")

  expect_error(tdm_metrics())
  expect_error(tdm_metrics("kdkd"))
  expect_error(tdm_metrics(select(out$tdm, -content_version)))

})

test_that("tdm are reported", {
  expect_s3_class(tdm_metrics(out$tdm) %>% ind_table_to_gt(.color = "red"), "gt_tbl")
})

## funder compliance

test_that("funder_metrics works", {
  a <- funder_metrics(out$funder_info)

  # dimensions and type
  expect_equal(ncol(a), 3)
  expect_s3_class(a, "data.frame")

  expect_error(funder_metrics())
  expect_error(funder_metrics("kdkd"))
  expect_error(funder_metrics(select(out$funder_info, -name)))
})

test_that("funder_metrics are reported", {
  expect_s3_class(funder_metrics(out$funder_info) %>% ind_table_to_gt(.color = "red"), "gt_tbl")
})
