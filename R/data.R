#' Some DOIs for testing
#' @export
tu_dois <- function() {
  readr::read_lines(file = system_file2("extdata", "tu_dois.txt"))
}
install.packages("future.callr")
