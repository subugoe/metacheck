# packrat dark magic does not recognise the subugoetheme dependency
# this hack fixes that by just calling some random function
subugoetheme::ejd_pal()
# relative path
source("env_secrets.R")
shiny::shinyApp(ui = metacheck:::mcAppUI(), server = metacheck:::mcAppServer)
