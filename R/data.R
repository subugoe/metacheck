#' Some DOIs for testing
#' @noRd 
tu_dois <- function() {
  readr::read_lines(file = system_file2("extdata", "dois", "tu.txt"))
}

#' Long list of DOIs
#' @noRd
dois_many <- function() {
  res <- readr::read_lines(file = system_file2("extdata", "dois", "many.txt"))
  biblids::as_doi(res)
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
    "10.1000/3", # would exceed limit of 4
    # caused issues in https://github.com/subugoe/metacheck/issues/181
    "10.1007/s00330-019-06284-8",
    # caused issues in https://github.com/subugoe/metacheck/issues/181
    "10.1007/s00431-018-3217-8"
  )
}
