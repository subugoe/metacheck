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
  } else if (has_creds_key()) {
    res <- creds_key_metacheck()
  } else {
    rlang::abort("No SMTP credentials found.")
  }
  res
}

#' Configuration for outbound SMTP
#' @noRd
metacheck_outbund <- function() {
  list(
    user = "7dd3848a47e310558c101fefb4d8edc5",
    host = "in-v3.mailjet.com",
    port = 587,
    use_ssl = TRUE
  )
}

#' Supply SMTP secret from env var
#' 
#' Useful in cloud settings with secret env vars.
#' @noRd
creds_envvar_metacheck <- function() {
  rlang::exec(
    blastula::creds_envvar,
    !!!metacheck_outbund(),
    pass_envvar = "MAILJET_SMTP_PASSWORD"
  )
}

has_creds_envvar <- function() Sys.getenv("MAILJET_SMTP_PASSWORD") != ""

#' Supply SMTP secret from key-value store
#' 
#' Useful for local testing and debugging.
#' Only works interactively.
#' @noRd
creds_key_metacheck <- function() blastula::creds_key("metacheck_outbound")

#' Store SMTP credentials in the system's key-value store
#' @noRd
create_smtp_creds_key_metacheck <- function() {
  rlang::exec(
    blastula::create_smtp_creds_key,
    !!!metacheck_outbund(),
    id = "metacheck_outbound"
  )
}

has_creds_key <- function() {
  "metacheck_outbound" %in% blastula::view_credential_keys()$id
}

can_auth_smtp <- function() has_creds_envvar() | has_creds_key()

skip_if_not_smtp_auth <- function() {
  ifelse(can_auth_smtp(), invisible(TRUE), skip("No SMTP auth available."))
}
