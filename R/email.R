#' Render email
#' @param dois Character vector of DOIs
#' @param session_id Character vector to identify current shiny session
#' @export
render_email <- function(dois, session_id = NULL) {
  cr <- get_cr_md(dois)
  my_df <- cr_compliance_overview(cr)
  email <- blastula::compose_email(
    header = "metacheck: Open Access Metadata Compliance Checker",
    body = blastula::render_email(
      input = system.file(
        "rmarkdown/templates/email/reply_success_de/reply_success_de.Rmd",
        package = "metacheck"
      ),
      render_options = list(
        params = list(
          dois = dois,
          cr_overview = my_df$cr_overview,
          cr_license = my_df$cc_license_check,
          cr_tdm = my_df$tdm,
          cr_funder = my_df$funder_info,
          open_apc = my_df$open_apc_info,
          session_id = session_id
        )
      )
    )$html_html,
    footer = blastula::md(c(
      "Email sent on ", format(Sys.time(), "%a %b %d %X %Y"), "."
    ))
  )
  email <- add_attachment_xlsx(email, session_id = session_id)
  email
}

#' Add attachment to email
#' @inheritParams blastula::add_attachment
#' @export
add_attachment_xlsx <- function(email, session_id = NULL) {
  blastula::add_attachment(
    email = email,
    file = xlsx_path(session_id),
    filename = "metadata_report.xlsx"
  )
}


#' Temp path to write xlsx to
#' @inheritParams render_email
xlsx_path <- function(session_id = NULL) {
  fs::path_temp(paste0(session_id, "-license_df.xlsx"))
}

# sending ====

#' Send out email
#' @inheritParams blastula::smtp_send
#' @inheritDotParams blastula::smtp_send
#' @family communicate
#' @keywords internal
#' @export
smtp_send_metacheck <- function(email,
                                to,
                                from = "metacheck-support@sub.uni-goettingen.de",
                                subject = "OA-Metadaten-Schnelltest: Ihr Ergebnis",
                                cc = from,
                                credentials = creds_metacheck(),
                                verbose = FALSE) {
  blastula::smtp_send(
    email = email,
    to = to,
    from = from,
    subject = subject,
    cc = cc,
    credentials = credentials,
    verbose = verbose
  )
  invisible(email)  # best practice
}

#' Get credentials for smtp
#' @noRd
creds_metacheck <- function() {
  if (has_creds_envvar()) {
    res <- creds_envvar_metacheck()
  } else {
    rlang::abort("No SMTP credentials found.")
  }
  res
}

#' Supply SMTP secret from env var
#' @noRd
creds_envvar_metacheck <- function() {
  blastula::creds_envvar(
    user = "7dd3848a47e310558c101fefb4d8edc5",
    pass_envvar = "MAILJET_SMTP_PASSWORD",
    host = "in-v3.mailjet.com",
    port = 587,
    use_ssl = TRUE
  )
}

has_creds_envvar <- function() Sys.getenv("MAILJET_SMTP_PASSWORD") != ""

skip_if_not_smtp_auth <- function() {
  ifelse(has_creds_envvar(), invisible(TRUE), skip("No SMTP auth available."))
}
