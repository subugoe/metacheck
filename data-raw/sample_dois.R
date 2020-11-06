## code to prepare `sample_dois` dataset goes here
library(readr)
library(usethis)
o_apc <- readr::read_csv("https://raw.githubusercontent.com/OpenAPC/openapc-de/master/data/apc_de.csv")
sample_dois <- sample(o_apc$doi, 200)

usethis::use_data(sample_dois, overwrite = TRUE)
