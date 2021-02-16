test_that("license md checker works (Delayed licenses)",
          {
            delayed_sample <- c(
              "10.1007/s10444-020-09763-5",
              "10.1007/s12268-020-1368-4",
              "10.1140/epje/i2020-11949-8",
              "10.1007/s42048-020-00069-1",
              "10.1007/s00348-020-02979-7",
              "10.1140/epje/i2020-11975-6",
              "10.1140/epjst/e2020-900253-0",
              "10.1631/jzus.A2000033"
            )
            my_df <- get_cr_md(delayed_sample)
            out <- license_check(my_df)
            # correct classes
            checkmate::expect_tibble(out)
            # correct validation
            expect_match(
              unique(out$check_result),
              "Difference between publication date and the CC license's start_date suggests delayed OA provision"
            )
            # correct dimensions
            expect_equal(nrow(out), 8)
          })
