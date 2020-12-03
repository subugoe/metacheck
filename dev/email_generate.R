tu_dois <- readLines("data-raw/tu_dois.txt")
# get data
cr <- get_cr_md(tu_dois,.progress = "text")
# cr <- get_cr_md("10.1016/j.joi.2016.08.002", "10.3153/jfhs15007")
# cr_test <-get_cr_md(c("10.3153/jfhs15007", "10.3153/jfhs15008"))
# compliance check
my_df <- cr_compliance_overview(cr)
email <- blastula::compose_email(
  header = "Open-Access-Metadaten-Schnelltest",
  body = blastula::render_email("inst/rmarkdown/templates/email/reply_success_de/reply_success_de.Rmd",
                                render_options = list(params = list(
                                  dois = tolower(tu_dois),
                                  cr_overview = my_df$cr_overview,
                                  cr_license=my_df$cc_license_check,
                                  cr_tdm=my_df$tdm,
                                  cr_funder=my_df$funder_info,
                                  open_apc = my_df$open_apc_info)))$html_html,
  footer = blastula::md(c(
    "Email sent on ", format(Sys.time(), "%a %b %d %X %Y"), "."
  ))
)
# test
email
file <- paste0(tempdir(), "/license_df.xlsx")

# send
 email %>%
   # attachment
   blastula::add_attachment(
     file,
     content_type = mime::guess_type(file),
     filename = "metadata_report.xlsx"
   ) %>%
   blastula::smtp_send(
     subject = "HOAD Compliance Check Ergebnis",
     cc = "najko.jahn@sub.uni-goettingen.de",
     from = "najko.jahn@gmail.com",
     to = "michaela.voigt@tu-berlin.de",
     credentials = blastula::creds(
       user = "7dd3848a47e310558c101fefb4d8edc5",
       host = "in-v3.mailjet.com",
       port = 587,
       use_ssl = TRUE
       )
    )
