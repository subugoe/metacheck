skip_if_offline()
dois <- c("10.1038/s41598-020-57429-5",
          "10.3389/fmech.2019.00073",
          "10.1038/s41598-020-62245-y")
req <- get_cr_md(dois)
out <- cr_compliance_overview(req)

test_that("cr_compliance_overview returns list with named tibbles", {
  testthat::expect_type(out, "list")
  testthat::expect_s3_class(out$cr_overview, "tbl_df")
  testthat::expect_s3_class(out$cc_license_check, "tbl_df")
  testthat::expect_s3_class(out$tdm, "tbl_df")
  testthat::expect_s3_class(out$funder_info, "tbl_df")
})

test_that("indicators overview calculation works", {
  tt <- out$cr_overview
  expect_true(
    unlist(tt[tt$doi == "10.1038/s41598-020-62245-y", "has_cc"])
  )
  expect_true(
    unlist(tt[tt$doi == "10.1038/s41598-020-62245-y", "has_compliant_cc"])
  )
  expect_false(
    unlist(tt[tt$doi == "10.3389/fmech.2019.00073", "has_tdm_links"])
           )
  expect_false(
      unlist(tt[tt$doi == "10.3389/fmech.2019.00073", "has_orcid"])
    )
  expect_true(
    unlist(tt[tt$doi == "10.1038/s41598-020-57429-5", "has_open_abstract"])
  )
  expect_true(
    unlist(tt[tt$doi == "10.1038/s41598-020-57429-5", "has_open_refs"])
  )
})
