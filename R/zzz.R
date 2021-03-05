.onLoad <- function(libname, pkgname) {
  # for details see import.R
  memoised_cr_works <<- memoise::memoise(insistently_cr_works)
}
