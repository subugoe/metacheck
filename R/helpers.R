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
