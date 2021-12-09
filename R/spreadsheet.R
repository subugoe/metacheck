#' Store individual results in a spreadsheet
#' @details `r metacheck::mc_long_docs_string("spreadsheet.md")`
#' @family communicate
#' @name spreadsheet
NULL

#' @describeIn spreadsheet Create individual results
#' @return A list of tibbles
#' @inheritParams report
#' @export
create_ss <- function(dois = doi_examples$good[1:10]) {
  df <- cr_compliance_overview(get_cr_md(dois[is_metacheckable(dois)]))
  df[["pretest"]] <- tibble::tibble(
    # writexl does not know vctrs records
    doi = as.character(biblids::as_doi(dois)),
    tabulate_metacheckable(dois)
  )
  df
}

#' @describeIn spreadsheet Write out file
#' @inheritParams writexl::write_xlsx
#' @inheritDotParams writexl::write_xlsx
#' @export
write_xlsx_mc <- function(x, path = fs::file_temp(ext = "xlsx"), ...) {
  writexl::write_xlsx(
    x = x,
    path = path,
    ...
  )
}

#' @describeIn spreadsheet Attach file to email
#' @inheritParams blastula::add_attachment
#' @export
add_attachment_mc <- function(email = blastula::prepare_test_message(), 
                              file,
                              translator = mc_translator()) {
  blastula::add_attachment(
    email = email,
    file = file,
    filename = translator$translate("mc_individual_results.xlsx")
  )
}

#' @describeIn spreadsheet Create and attach individual results to email
#' @export
create_and_attach_ss <- function(dois = doi_examples$good[1:10], ...) {
  ellipsis::check_dots_used()
  df <- create_ss(dois = dois)
  add_attachment_mc(file = write_xlsx_mc(df), ...)
}
