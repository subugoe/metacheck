#' Translations for metacheck
#' @noRd
mc_translator <- shiny.i18n::Translator$new(
  translation_json_path = system.file(
    package = "metacheck",
    "i18n",
    "translation.json"
  )
)
