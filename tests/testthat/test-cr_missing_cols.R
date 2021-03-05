test_that("Missing funder info is captured", {
  dois <- c(
    "10.1046/j.1472-8206.2001.00030.x",
    "10.1007/s10687-011-0143-9",
    "10.1017/s0307883300011135"
  )
  req <- get_cr_md(dois)

  a <- cr_funder_df(req)
  # dimensions and type
  expect_equal(nrow(a), 3)
  expect_s3_class(a, "data.frame")

  b <- funder_metrics(a)
  testthat::expect_snapshot(b)
})

test_that("Missing tdm info is captured", {
  dois <- c("10.3892/ijmm.2019.4140",
            "10.46300/9101.2020.14.21")
  req <- get_cr_md(dois)

  a <- cr_tdm_df(req)
  # dimensions and type
  expect_equal(nrow(a), 2)
  expect_s3_class(a, "data.frame")

  b <- tdm_metrics(a)
  testthat::expect_snapshot(b)
})
