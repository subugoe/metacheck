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

#' Send out email
#' @inheritParams blastula::smtp_send
#' @export
send_email <- function(to, email, cc = "metacheck-support@sub.uni-goettingen.de") {
  blastula::smtp_send(
    email = email,
    subject = "OA-Metadaten-Schnelltest: Ihr Ergebnis",
    cc = cc,
    from = "metacheck-support@sub.uni-goettingen.de",
    to = to,
    credentials = blastula::creds_envvar(
      user = "7dd3848a47e310558c101fefb4d8edc5",
      host = "in-v3.mailjet.com",
      port = 587,
      use_ssl = TRUE,
      pass_envvar = "MAILJET_SMTP_PASSWORD"
    )
  )
}

#' Temp path to write xlsx to
#' @inheritParams render_email
xlsx_path <- function(session_id = NULL) {
  fs::path_temp(paste0(session_id, "-license_df.xlsx"))
}