#' Report Metadata Compliance
#' 
#' Helper functions to generate a metacheck report.
#' 
#' @note `r metacheck::mc_long_docs_string("disclaimer_fe.md")`
#' 
#' @family communicate
#' @name report
NULL

#' @describeIn report Path to template
#' @noRd
path_report_template <- function(lang = mc_langs) {
  stopifnot(!shiny::is.reactive(lang))
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
#' @param lang Character scalar giving the anguage of the report.
#' *Not* reactive as in [mcControlsServer()].
#' @inheritDotParams rmarkdown::draft
#' @export
draft_report <- function(lang = mc_langs, ...) {
  rmarkdown::draft(..., template = path_report_template(lang), package = NULL)
}

#' @describeIn report
#' Render a parametrised metacheck report.
#' @param dois
#' Vector of DOIs, as created by, or coerceable to [biblids::doi()].
#' @inheritDotParams rmarkdown::render
#' @inheritParams mcControlsServer
#' @export
render_report <- function(dois = doi_examples$good,
                          translator = mc_translator(),
                          ...) {
  stopifnot(!shiny::is.reactive(dois))
  checkmate::assert_vector(dois, min.len = 1, null.ok = FALSE)
  dois <- biblids::as_doi(dois)
  # some runtimes (shinyapps.io) can't write to folders R_HOME
  # which render would otherwise do
  temp_template <- fs::file_copy(
    path = path_report_rmd(lang = translator$get_translation_language()),
    new_path = fs::file_temp(ext = ".Rmd"),
    overwrite = TRUE
  )
  rmarkdown::render(
    input = temp_template,
    params = list(dois = dois, translator = translator),
    ...
  )
}

#' @describeIn report
#' Render report as a child document.
#' Used inside vignettes.
#' @noRd
knit_child_report <- function(...) {
  # knit_child does not know params, so these have to be in env
  params <<- list(dois = doi_examples$good)
  res <- knitr::knit_child(
    path_report_rmd(...),
    quiet = TRUE
  )
  cat(res, sep = "\n")
}
