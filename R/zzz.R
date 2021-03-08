.onLoad <- function(libname, pkgname) {
  # for details see import.R
  memoised_cr_works <<- memoise::memoise(insistently_cr_works)
  memoised_possibly_cr_works_field <<- memoise::memoise(possibly_cr_works_field)
}
