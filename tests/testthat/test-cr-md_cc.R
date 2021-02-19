test_that("license md checker works (Delayed licenses)",
          {
            delayed_sample <- c(
              "10.1007/s10444-020-09763-5",
              "10.1007/s12268-020-1368-4",
              "10.1140/epje/i2020-11949-8"
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
            expect_equal(nrow(out), 3)
          })

test_that("license md checker works (vor)",
         {
           vor_sample <- c(
             "10.36900/suburban.v8i1/2.559",
             "10.3389/fpsyg.2020.00097",
             "10.1109/access.2020.2977087"
           )
           my_df <- get_cr_md(vor_sample)
           out <- license_check(my_df)
           # correct classes
           checkmate::expect_tibble(out)

           # correct dimensions
           expect_equal(nrow(out), 3)

           # correct validation
           checkmate::checkString(unlist(
             out[out$doi == "10.36900/suburban.v8i1/2.559", "check_result"]),
                        "No Creative Commons license metadata found for version of record")
           checkmate::checkString(unlist(
             out[out$doi == "10.3389/fpsyg.2020.00097", "check_result"]),
             "All fine!")
           checkmate::checkString(unlist(
             out[out$doi == "10.1109/access.2020.2977087", "check_result"]),
             "No Creative Commons license found")
         })
