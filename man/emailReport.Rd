% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/email.R
\name{emailReport}
\alias{emailReport}
\alias{emailReportUI}
\alias{emailReportServer}
\title{Email Report through a Shiny Module}
\usage{
emailReport()

emailReportUI(id, width = "100\%", translator = mc_translator(), ...)

emailReportServer(
  id,
  dois = shiny::reactive(NULL),
  translator = mc_translator(),
  lang = shiny::reactive("en")
)
}
\arguments{
\item{id}{The id string to be namespaced (optional).}

\item{width}{The width of the input, e.g. \code{'400px'}, or \code{'100\%'};
see \code{\link[shiny:reexports]{validateCssUnit()}}.}

\item{translator}{A \link[shiny.i18n:Translator]{shiny.i18n::Translator} object or \code{NULL} for english-only defaults.
Strings inside the module UI are marked as translateable.
You can pass a translator object included in the package,
or can create your own \code{translator} using \link[shiny.i18n:Translator]{shiny.i18n::Translator}.
This must not be a reactive, it is only set at shiny startup.
To update the language reactively \emph{during} a shiny session, see \code{lang}.}

\item{...}{
  Arguments passed on to \code{\link[shiny:actionButton]{shiny::actionButton}}
  \describe{
    \item{\code{inputId}}{The \code{input} slot that will be used to access the value.}
    \item{\code{label}}{The contents of the button or link--usually a text label, but
you could also use any other HTML, like an image.}
    \item{\code{icon}}{An optional \code{\link[shiny:icon]{icon()}} to appear on the button.}
  }}

\item{lang}{a reactive variable, returning a character scalar.
Must be one of the languages in \code{translator}.
Defaults to \code{shiny::reactive("en")},
in which case no server side translation
is triggered.}
}
\description{
Email Report through a Shiny Module
}
\section{Related Functions and Methods}{
\subsection{Functions}{
\itemize{
\item \code{emailReport}: Test app
}
\itemize{
\item \code{emailReportUI}: Module UI
}
\itemize{
\item \code{emailReportServer}: Module server
}}}

\seealso{
Other communicate: 
\code{\link{email}},
\code{\link{mcApp}()},
\code{\link{mcControls}},
\code{\link{md_data_attachment}()},
\code{\link{report}},
\code{\link{runMetacheck}()}
}
\concept{communicate}
\keyword{internal}
