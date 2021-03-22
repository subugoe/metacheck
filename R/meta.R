# Includes structured information about the project
# All unexported, untested, unasserted
# Why is this in the pkg at all?
# So that it can programmatically be called from different contexts
# (shiny, Rmd, etc.)

# events ====

#' Create event
#' 
#' @param `topic`,`desc` topic/title and description of the event
#' @param `start`, `end` a vector of POSIXt, numeric or character objects
#' @param `lang` language of the event.
#' @param `type` type of event.
#' @param `link_reg`,`link_atd` links to registration and attendance.
#' @param `n_reg`, `n_atd` number of registered and attending.
#' @inheritParams lubridate::as_datetime()
#'
#' @noRd
event <- function(topic,
                  desc,
                  start,
                  end = lubridate::as_datetime(start, tz = tz) + lubridate::hours(1L),
                  lang = c("de-DE", "en-US"),
                  type = c("Webinar"),
                  link_reg = NA,
                  link_atd = NA,
                  n_reg = NA,
                  n_atd = NA,
                  tz = "Europe/Berlin") {
  lang <- rlang::arg_match(lang)
  type <- rlang::arg_match(type)
  list(
    topic = topic,
    desc = desc,
    start = lubridate::as_datetime(start, tz = tz),
    end = lubridate::as_datetime(end, tz = tz),
    lang = lang,
    type = type,
    link_reg = link_reg,
    link_atd = link_atd,
    n_reg = n_reg,
    n_atd = n_atd
  )
}

#' @describeIn event Create multiple events
#' Accepts vectors for each arg, recycles as and returns tibble.
#' @noRd
events <- function(...) {
  x <- tibble::tibble(...)
  x_list <- vector(mode = "list", length = nrow(x))
  for (i in 1:nrow(x)) {
    x_list[[i]] <- rlang::exec(event, !!!x[i, ])
  }
  purrr::map_dfr(x_list, tibble::as_tibble_row)
}

#' Webinars after beta release
#' @noRd
webinare_beta <- events(
  topic = "Vorstellung OA-Metadaten-Schnelltest (Beta)",
  desc = glue::glue(
    "Im Webinar wird der OA-Metadaten-Schnelltest und die dahinter liegende Methodik zur Diskussion vorgestellt. ",
    "Die Veranstaltung richtet sich in erster Linie an Personen, die an Bibliotheken und Informationseinrichtungen einen Publikationsfonds oder Transformationsvertr\U00E4ge betreuen. ",
    "Teilnehmende haben die M\U00F6glichkeit, sich in die Projektentwicklung einzubringen und im Webinar ihre Anforderungen und Erfahrungen zu teilen. "
  ),
  start = c("2021-03-19 11:00:00", "2021-03-30 09:00:00", "2021-04-15 14:00:00"),
  link_reg = c(
    "https://uni-goettingen.zoom.us/meeting/register/tJ0sd-igrDosHdOT-BkziQBFtkacrk0o5WrG",
    "https://uni-goettingen.zoom.us/meeting/register/tJEtfumqrTMvEtXtLrnT1m_Jn135Otcv6tOA",
    "https://uni-goettingen.zoom.us/meeting/register/tJIrcOmqqTkiH9wd7DoKTC94vx2NQJR_EHfy"
  )
)

#' Our events
#' @noRd
metacheck_events <- rbind(webinare_beta)

#' Print an event events to HTML
#' 
#' Creates a bootstrap (3.4) `"list-group".
#' 
#' @details
#' Because there is no class, this is not a proper knit_print method.
#' It's just named thus to be expressive.
#' 
#' @param x a tibble of events as returned by [events()].
#' 
#' @noRd
knit_print.events <- function(x = metacheck_events) {
  if (nrow(x) == 0) return(knitr::asis_output(x = ""))
  # let's make a list first for purrr
  x_list <- split(x, seq(nrow(x)))
  htmltools::div(
    class = "list-group",
    purrr::map(x_list, knit_print.event)
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
      x$topic,
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
      knit_print.btns(x$link_reg, x$link_atd, x$n_reg, x$n_atd, x$end, x$lang)
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
#' @inheritParams event
#' @noRd
knit_print.btns <- function(link_reg,
                            link_atd,
                            n_reg,
                            n_atd,
                            end,
                            lang) {
  reg <- NULL
  if (end >= Sys.time()) {
    reg <- htmltools::a(
      class = "btn btn-default btn-sm",
      href = link_reg,
      switch(lang, `de-DE` = "Jetzt anmelden", `en-US` = "Register now")
    )
    atd <- htmltools::a(
      class = "btn btn-primary btn-sm",
      href = link_atd,
      switch(lang, `de-DE` = "Jetzt teilnehmen", `en-US` = "Participate now")
    )
  } else {
    atd <- htmltools::a(
      class = "btn btn-default btn-sm",
      href = link_atd,
      switch(lang, `de-DE` = "Teilnehmer_innen", `en-US` = "Participants"),
      if (!is.na(n_atd)) {
        htmltools::span(
          class = "badge", n_atd
        )
      }
    )
  }
  htmltools::p(class = "list-group-item-text", reg, atd)
}
