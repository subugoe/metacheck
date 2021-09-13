#' Translations for metacheck
#' @noRd
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
