#' Translations for metacheck
#' @export
#' @keywords internal
mc_translator <- function() {
  shiny.i18n::Translator$new(
    translation_json_path = system.file(
      package = "metacheck",
      "i18n",
      "translation.json"
    )
  )
}

#' Available languages for metacheck
#' @export
#' @keywords internal
mc_langs <- mc_translator()$get_languages()

#' Long translations for metacheck
#' 
#' Longer translations are included as separate `*.md` files,
#' and are not covered in `translation.json` powering [mc_translator()].
#' 
#' @inheritParams draft_report
#' @inheritParams base::system.file
#' 
#' @keywords internal
#' @export
mc_long_docs <- function(..., lang = mc_langs) {
  lang <- rlang::arg_match(lang)
  system_file2("long_docs", lang, ...)
}

#' @describeIn mc_long_docs Return content of file
#' @keywords internal
#' @export
mc_long_docs_string <- function(...) {
  readr::read_file(mc_long_docs(...))
}
