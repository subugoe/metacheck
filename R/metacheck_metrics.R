#' Measure DOI indexing status
#'
#' Check the extent to which DOIs are available through Crossref
#'
#' @param dois character vector, submitted DOIs
#' @param .md list, returned from [cr_compliance_overview()]
#' @importFrom glue glue
#'
#' @export
indexing_status <- function(dois = NULL, .md = NULL) {
  if(is.null(dois))
    stop("No DOIs provided")
  if(is.null(.md$cr_overview))
    stop("No Crossref metadata provided")
  else
    if(setequal(tolower(dois), tolower(.md$cr_overview$doi))) {
      out <- msg_all_dois_found(dois = dois)
    } else {
      out <- msg_dois_missing(dois = dois, .md = .md)
    }
  out
}

#' Success message
#' @param dois character vector, submitted DOIs
#'
#' @noRd
msg_all_dois_found <- function(dois = dois) {
  glue::glue("Für alle DOIs (n={length(unique(dois))}) sind Crossref Metadaten vorhanden.")
}

#' Report missing some DOIs
#'
#' @noRd
msg_dois_missing <-  function(dois, .md) {
  out <- glue::glue(
    "
**{length(unique(tolower(.md$cr_overview$doi)))}** von **{length(unique(tolower(dois)))}** DOIs sind in Crossref indexiert.

Die folgenden DOIs sind **nicht** bei Crossref registriert:

* {glue::glue_collapse(dois[!tolower(dois) %in% tolower(.md$cr_overview$doi)], sep = '\n* ')}
 "
  )
 out
}
