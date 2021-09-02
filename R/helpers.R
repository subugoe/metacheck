#' Access metacheck files
#' @noRd
system_file2 <- function(...) {
  system.file(..., package = "metacheck")
}

#' Validate email
#' @noRd
is_valid_email <- function(x) {
  grepl(
    "^\\s*[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\s*$",
    as.character(x),
    ignore.case = TRUE
  )
}

# run predicates transitively ====

#' Run predicates transitively
#' 
#' Assumes that if a predicate on the left is `FALSE`,
#' the succeeding one on the right will also be `FALSE`
#' and can thus be skipped.
#' 
#' @details
#' When checking data (such as bibliometric metadata)
#' against several criteria of compliance (such as uniqueness, syntax), 
#' two conditions can hold:
#' 
#' 1. The criteria is an **aggregate phenomenon**,
#'    such as in the case of uniqueness.
#'    It does not make sense to ask if any *individual* data element is unique,
#'    but the entire data vector must be unique.
#'    Happily, this condition is "downward compatible":
#'    If the criteria is an individual phenomenon (such as syntax),
#'    it can also tested in vectorised form against the entire vector.
#' 2. The criteria may be in some **transitive order.**
#'    For example, if a value `is.integer()` it will also be `is.numeric()`;
#'    an integer is a special case of a numeric value.
#'    Typically, these criteria may be listed in decreasing order of generality:
#'    You'd *first* test if something is `is.numeric()`
#'    and *then* whether it's also `is.integer()`.
#'    Formally, this means that predicate functions may be given in
#'    **negative transitive order**,
#'    where .lf[n](.z) == FALSE` implies `.lf[n+1](.z) == FALSE`.
#'    
#'    Abstracting away these ordered predicates with functional programming
#'    brings significant benefits:
#'    1. It saves computation.
#'       If `.lf[n+1](.z)` is already known to be `FALSE`,
#'       it need not be run.
#'    2. It helps improve expressiveness and reduces complexity of the
#'       predicates.
#' 
#' @param .z A list or atomic vector.
#' 
#' @param .lf A list of predicate functions.
#' 
#' @param ... Additional named arguments to `.lf`.
#' 
#' @return 
#' A dataframe of logical vectors, one column per predicate function.
#' Skipped predicate tests return a `NA`.
#' 
#' @family helpers
#' 
#' @export
accumulate_pred_trans <- function(.z, .lf, ...) {
  checkmate::assert_list(.lf, types = "function", any.missing = FALSE)
  funlist <- purrr::map(.lf, transitively)
  res <- purrr::accumulate(
    .x = funlist,
    # this could also be done with purrr::map_if as a function
    # which is a 2 arg fun already
    # however, this would run the predicate *twice*,
    # once as .f and then as .p
    # so passing on the result as a logical vector is more efficient
    .f = function(.prior, .fun, .z, ...) {
      rlang::exec(.fun, .x = .z, .prior = .prior, ...)
    },
    .z = .z,
    .init = rep(TRUE, length(.z)),
    ...
  )
  # first list result is spurious
  tibble::as_tibble(res[c(2:length(res))])
}

#' Adverb to let predicate functions default to `NA`
#'
#' @param .p A predicate function.
#' @describeIn accumulate_pred_trans
#' Adverb to let predicate functions default to `NA` for `.x[!.prior]`.
#' Creates a function with two arguments:
#' - `.x`: An object to apply `.p` to.
#' - `.prior`: A logical vector,
#'    where `FALSE` or `NA` implies that `.p(.x)` should not be run
#'    but default to `NA`.
#' - ...: Other arguments passed to `.p()`.
transitively <- function(.p, ...) {
  function(.x, .prior, ...) {
    stopifnot(rlang::is_logical(.prior))
    stopifnot(length(.x) == length(.prior))
    .prior[is.na(.prior)] <- FALSE  # simplifies below subsetting
    res <- rep(NA, length(.x))  # set up default value
    # weird but necessary protection; we're done when all are FALSE
    if (!any(.prior)) {
      return(res)
    }
    # again a simple map_if does not seem to work,
    # because we depend on logical .prior not just a .p(.x).
    # map_at, conversely, does not provide an `.else` (`NA` in this case)
    # this is vulnerable to vctrs records class,
    # which will be incorrectly subset as per
    # https://github.com/tidyverse/purrr/issues/819
    res[.prior] <- purrr::map_lgl(.x[.prior], .p, ...)
    res
  }
}

#' Check whether context is production
is_prod <- function() {
  # this works for Azure only
  # https://docs.microsoft.com/en-us/azure/app-service/reference-app-settings?tabs=kudu%2Cdotnet
  # TODO should be factored out, used from shinycaas
  Sys.getenv("WEBSITE_SLOT_NAME" == "Production")
}
