# used often b/c plain json doesn't cover complex objects
expect_snapshot_value2 <- purrr::partial(expect_snapshot_value, style = "json2")
