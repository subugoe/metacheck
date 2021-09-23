# ==== example dois

#' DOIs included in the package for testing and illustration
#' @format A list of [biblids::doi()] vectors, including:
#' - `good`: Guaranteed to work (all are [is_metacheckable()]).
#' - `many`: Long list of DOIs.
#' - `weird`: Troublesome DOIs.
#' - `biblids`: [biblids::doi_examples()]
#' 
#' @examples
#' doi_examples$good
#' 
#' @family data
#' @export
doi_examples <- list(
  # these are originally from TU users
  good = biblids::as_doi(
    readr::read_lines(
      file = system.file("extdata", "dois", "tu.txt", package = "metacheck"))
  ),
  many = biblids::as_doi(
    readr::read_lines(
      file = system.file("extdata", "dois", "many.txt", package = "metacheck")
    )
  ),
  weird = biblids::as_doi(
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
      "10.1007/s00431-018-3217-8",
      "10.3389/fmech.2020.566440/full"  # superfluous url fragment
    )
  ),
  biblids = biblids::doi_examples()
)
