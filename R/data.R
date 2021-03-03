#' Some DOIs for testing
#' @noRd 
tu_dois <- function() {
  readr::read_lines(file = system_file2("extdata", "tu_dois.txt"))
}

#' Some troublesome DOIs for testing
#' @noRd
dois_weird <- function() {
  c(
    # these are roughly in the order of metacheckable predicates
    "10.1000/1",
    NA, # there's no meaningful metadata for an NA DOI
    "doi:10.1000/1", # duplicated from above
    "10.3389/fbioe.2020.00209", # actually from CR
    "10.1000/2",
    "10.1000/3" # would exceed limit of 4
  )
}
