#' Report Metadata Compliance
#' 
#' Helper functions to generate a metacheck report.
#' 
#' @family communicate
#' @name report
NULL

#' @describeIn report Path to template
#' @noRd
path_report_template <- function(lang = c("en", "de")) {
  lang <- rlang::arg_match(lang)
  switch(lang,
    en = system_file2("rmarkdown", "templates", "report"),
    de = system_file2("rmarkdown", "templates", "bericht")
  )
}

#' @describeIn report Path to rmd
#' @noRd
path_report_rmd <- function(...) {
  fs::path(path_report_template(...), "skeleton", "skeleton.Rmd")
}

#' @describeIn report 
#' Create a draft report from the template.
#' Useful for manual edits; equivalent to opening a new template in RStudio.
#' @param lang Language of the report.
#' @inheritDotParams rmarkdown::draft
#' @export
draft_report <- function(lang = c("en", "de"), ...) {
  rmarkdown::draft(..., template = path_report_template(lang), package = NULL)
}

#' @describeIn report
#' Render a parametrised metacheck report.
#' @param dois
#' Vector of DOIs, as created by, or coerceable to [biblids::doi()].
#' @inheritDotParams rmarkdown::render
#' @export
render_report <- function(dois, lang = c("en", "de"), ...) {
  dois <- biblids::as_doi(dois)
  checkmate::assert_vector(dois, min.len = 2, null.ok = FALSE)
  rmarkdown::render(
    input = path_report_rmd(lang = lang),
    params = list(dois = dois),
    ...
  )
}

#' @describeIn report
#' Render report as a child document.
#' Used inside vignettes.
#' @noRd
knit_child_report <- function(...) {
  # knit_child does not know params, so these have to be in env
  params <<- list(dois = tu_dois())
  res <- knitr::knit_child(
    path_report_rmd(...),
    quiet = TRUE
  )
  cat(res, sep = "\n")
}