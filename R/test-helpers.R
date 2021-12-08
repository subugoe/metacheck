#' Throaway email recipient for testing
#' Recommended by https://stackoverflow.com/questions/1368163/is-there-a-standard-domain-for-testing-throwaway-email
#' @noRd
throwaway <- "whatever@mailinator.com"

#' Install metacheck in temp library path
#' Necessary for any testing in testthat with [future::multisession()]
#' @noRd
local_mc <- function(env = parent.frame()) {
  withr::local_temp_libpaths(.local_envir = env)
  remotes::install_local(
    path = usethis::proj_get(),
    dependencies = FALSE,
    upgrade = FALSE,
    force = TRUE
  )
}

#' Temporarily set future plan
#' @inheritParams future::strategy
#' @noRd
local_strategy <- function(strategy, env = parent.frame()) {
  old_plan <- future::plan(strategy = strategy)
  withr::defer(future::plan(old_plan), env = env)
}

#' Future strategies to be tested
#' @noRd
strategies <- list(
  sequential = future::sequential,
  multicore = future::multicore,
  multisession = future::multisession
)

#' Skipping unsupported strategies
skip_if_strategy_unsupported <- function(strategy_name = names(strategies)) {
  strategy_name <- rlang::arg_match(strategy_name)
  if (strategy_name == "multicore" && !future::supportsMulticore()) {
    return(testthat::skip("Multicore is not supported"))
  }
  if (strategy_name == "multisession" && testthat::is_parallel()) {
    return(testthat::skip(
      "Multisession futures cannot be tested inside parallel tests."
    ))
  }
  invisible(TRUE)
}

#' used often b/c plain json doesn't cover complex objects
#' @noRd
expect_snapshot_value2 <- purrr::partial(
  testthat::expect_snapshot_value,
  style = "json2"
)
