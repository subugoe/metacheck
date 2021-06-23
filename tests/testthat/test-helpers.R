test_that("accumulation of predicates works", {
  expect_equal(
    accumulate_pred_trans(
      # this is transitive but asymmetric
      # if x is integer, it is also numeric
      .lf = list(num = is.numeric, int = is.integer),
      .z = list(1.1, "a", 1L)
    ),
    tibble::tibble(
      num = c(TRUE, FALSE, TRUE),
      int = c(FALSE, NA, TRUE)
    )
  )
})

test_that("transitively adverb works", {
  is_integer_trans <- transitively(is.integer)
  expect_equal(
    is_integer_trans(list("a", "b", 1.1, 2L), c(NA, FALSE, TRUE, TRUE)),
    c(NA, NA, FALSE, TRUE)
  )
})
