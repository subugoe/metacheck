#' Some DOIs for testing
#' @noRd 
tu_dois <- function() {
  readr::read_lines(file = system_file2("extdata", "tu_dois.txt"))
}
