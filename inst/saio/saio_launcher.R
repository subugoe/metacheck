# packrat dark magic does not recognise the subugoetheme dependency
# this hack fixes that by just calling some random function
subugoetheme::ejd_pal()
shiny::shinyApp(
  ui = metacheck:::mcAppUI(),
  server = metacheck:::mcAppServer,
  onStart = function() {
    source("env_secrets.R")
    print(Sys.getenv())
    future::plan(future::sequential)
    library(metacheck)
    get_cr_md(x = doi_examples[[1]][1:10])
  }
)
