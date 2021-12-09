# better/stricter debugging of future, but slower
# see https://future.futureverse.org/articles/future-4-non-exportable-objects.html
withr::local_options(
  list(future.globals.onReference = "error"),
  .local_envir = testthat::teardown_env()
)
