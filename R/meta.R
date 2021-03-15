# Includes structured information about the project
# All unexported, untested, unasserted
# Why is this in the pkg at all?
# So that it can programmatically be called from different contexts
# (shiny, Rmd, etc.)

# events ====

#' Metacheck events
#'
#' These are our events
#'
#' @noRd
events <- function() {
  list(
    rlang::exec(
      event,
      !!!webinare_beta,
      start = "2021-03-19 11:00:00",
      end = "2021-03-19 12:00:00",
      link = "https://uni-goettingen.zoom.us/meeting/register/tJ0sd-igrDosHdOT-BkziQBFtkacrk0o5WrG",
      btns = htmltools::a(
        class = "btn btn-default btn-sm",
        href = "https://uni-goettingen.zoom.us/meeting/register/tJ0sd-igrDosHdOT-BkziQBFtkacrk0o5WrG",
        "Jetzt anmelden"
      )
    ),
    rlang::exec(
      event,
      !!!webinare_beta,
      start = "2021-03-19 11:00:00",
      end = "2021-03-19 12:00:00",
      link = "https://uni-goettingen.zoom.us/meeting/register/tJEtfumqrTMvEtXtLrnT1m_Jn135Otcv6tOA",
      btns = htmltools::a(
        class = "btn btn-default btn-sm",
        href = "https://uni-goettingen.zoom.us/meeting/register/tJEtfumqrTMvEtXtLrnT1m_Jn135Otcv6tOA",
        "Jetzt anmelden"
      )
    ),
    rlang::exec(
      event,
      !!!webinare_beta,
      start = "2021-03-30 09:00:00",
      end = "2021-03-30 10:00:00",
      link = "https://uni-goettingen.zoom.us/meeting/register/tJEtfumqrTMvEtXtLrnT1m_Jn135Otcv6tOA",
      btns = htmltools::a(
        class = "btn btn-default btn-sm",
        href = "https://uni-goettingen.zoom.us/meeting/register/tJEtfumqrTMvEtXtLrnT1m_Jn135Otcv6tOA",
        "Jetzt anmelden"
      )
    )
  )
}

#' Webinars after beta release
#' @noRd
webinare_beta <- list(
  topic = "Vorstellung OA-Metadaten-Schnelltest",
  desc = glue::glue(
    "Im Webinar wird der OA-Metadaten-Schnelltest und die dahinter liegende Methodik zur Diskussion vorgestellt. ",
    "Die Veranstaltung richtet sich in erster Linie an Personen, die an Bibliotheken und Informationseinrichtungen einen Publikationsfonds oder Transformationsvertr\U00E4ge betreuen. ",
    "Teilnehmende haben die M\U00F6glichkeit, sich in die Projektentwicklung einzubringen und im Webinar ihre Anforderungen und Erfahrungen zu teilen. "
  ),
  type = "Webinar"
)

#' Print an event events to HTML
#' 
#' Creates a bootstrap (3.4) `"list-group".
#' 
#' @details
#' Because there is no class, this is not a proper knit_print method.
#' It's just named thus to be expressive.
#' 
#' @param x list of events
#' 
#' @noRd
knit_print.events <- function(x = events()) {
  htmltools::div(
    class = "list-group",
    purrr::map(x, knit_print.event)
  )
}

#' Creates an event
#' 
#' @param topic,desc topic/title and description of the event
#' 
#' @param start,end
#' a vector of POSIXt, numeric or character objects
#' See [lubridate::as_datetime]
#' 
#' @inheritParams lubridate::as_datetime()
#' 
#' @param lang language of the event.
#' 
#' @param type type of event.
#' 
#' @param link link to the event.
#' 
#' @param btns [htmltools::tagList()] of buttons.
#' 
#' @return a named list
#' 
#' @noRd
event <- function(topic,
                  desc,
                  start,
                  end = NULL,
                  tz = "Europe/Berlin",
                  lang = "DE",
                  type = c("", "Webinar"),
                  link = "#",
                  btns = NULL
                  ) {
  type <- rlang::arg_match(type)
  list(
    topic = topic,
    desc = desc,
    start = lubridate::as_datetime(start, tz = tz),
    end = lubridate::as_datetime(end, tz = tz),
    lang = lang,
    type = type,
    link = link,
    btns = btns
  )
}

#' Print an event to HTML
#' 
#' Creates a
#' [bootstrap 3.4 list group element](https://getbootstrap.com/docs/3.4/components/#list-group)
#' 
#' @inherit knit_print.event_list
#' 
#' @param x a named list as returned by [event()]
#' 
#' @noRd
knit_print.event <- function(x) {
  htmltools::div(
    class = "list-group-item",
    htmltools::h4(
      class = "list-group-item-heading",
      `data-toc-skip` = TRUE,
      htmltools::a(
        href = x$link,
        x$topic
      ),
      htmltools::tags$small(
        class = "text-primary",
        htmltools::tags$time(
          class = "event__date",
          datetime = lubridate::format_ISO8601(x$start),
          glue::glue(
            format(x$start, format = "%d.%m.%Y %H:%M"),
            " -- ",
            format(x$end, format = "%H:%M")
          )
        ),
        knit_print.type(x$type),
      )
    ),
    htmltools::p(
      class = "list-group-item-text",
      x$desc,
      knit_print.btns(x$btns)
    )
  )
}

#' Knit print event type
#' @noRd
knit_print.type <- function(x) {
  if (x == "") return(NULL)
  btn_class <- switch(x,
    Webinar = "label-primary"
  )
  htmltools::tagList(
    # otherwise label bumps into time
    htmltools::span(" "),
    htmltools::span(class = paste("label", btn_class), x)
  )
}

#' Print many buttons
#' @noRd
knit_print.btns <- function(x) htmltools::div(class = "btn-group", x)
