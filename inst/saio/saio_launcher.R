# packrat dark magic does not recognise the subugoetheme dependency
# this hack fixes that by just calling some random function
subugoetheme::ejd_pal()
shiny::shinyApp(
  ui = metacheck:::mcAppUI(),
  server = metacheck:::mcAppServer,
  onStart = function() {
    source("env_secrets.R")
    future::plan(future::multicore, workers = 5L)
  }
)
