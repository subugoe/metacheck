#' Authorise crossref requests
#' 
#' Tries [crlite::get_cr_mailto()] and [crlite::get_cr_token()],
#' and sets env vars expected by rcrossref.
#' Does nothing otherwise, returns `FALSE` invisibly.
#'
#' @family helpers
#'
#' @export
#'
# TODO this should really live in the crossref client
# https://github.com/subugoe/metacheck/issues/248
auth_cr <- function() {
  mailto <- tryCatch(
    crlite::get_cr_mailto(),
    error = function(cond) character(1)
  )
  token <- tryCatch(
    crlite::get_cr_token(),
    error = function(cond) character(1)
  )
  if (mailto != "") Sys.setenv(crossref_email = mailto) else FALSE
  if (mailto != "") Sys.setenv(crossref_plus = token) else FALSE
}

#' Username used with password
#' @noRd
mailjet_username <- "7dd3848a47e310558c101fefb4d8edc5"

#' Mailjet smtps server
#' see https://documentation.mailjet.com/hc/en-us/articles/360043229473-How-can-I-configure-my-SMTP-parameters-
#' @noRd
mailjet_smtp_server <- "in-v3.mailjet.com"

#' Authorise mailjet requests
#' 
#' Tries the env var, then keyring and sets as env var.
#' Otherwise throws warning.
#' 
#' @family helpers
#' 
#' @export
# TODO this is a bit messy, b/c it is copying auth_cr()
auth_mailjet <- function() {
  from_envvar <- Sys.getenv("MAILJET_SMTP_PASSWORD")
  if (from_envvar != "") {
    rlang::inform(
      c("i" = "Using Mailjet password from env var `MAILJET_SMTP_PASSWORD`"),
      .frequency = "once",
      .frequency_id = "auth_mailjet"
    )
    return(invisible(TRUE))
  }
  from_keyring <- tryCatch(
    keyring::key_get(
      service = mailjet_smtp_server,
      username = mailjet_username
    ),
    error = function(x) {
      warning(
        "Could not find Mailjet SMTPs credentials;
        you may not be able to send out email."
      )
      return(character(1))
    }
  )
  if (from_keyring != "") {
    rlang::inform(
      c("i" = "Using Mailjet password from system keyring."),
      .frequency = "once",
      .frequency_id = "auth_mailjet"
    )
    return(Sys.setenv("MAILJET_SMTP_PASSWORD" = from_keyring))
  } else {
     return(invisible(FALSE))
  }
}
