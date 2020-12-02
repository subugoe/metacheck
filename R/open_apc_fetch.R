#' Get most current Open APC snapshot
#'
#' Open APC shares several csv files via GitHub, which contain data about
#' institutional spending for open access articles.
#'
#'
#' @param open_apc_cols character vector representing Open APC collections.
#'   See `open_apc_collections()` for an overview.
#'
#' @importFrom dplyr filter `%>%` inner_join
#' @importFrom purrr map_df
#'
#' @return Tibble with article-level subset of Open APC dataset including
#'   collection.
#'
#' @export
open_apc_get <- function(open_apc_cols = NULL) {
  req <- open_apc_collections() %>%
    filter(open_apc_collection %in% open_apc_cols) %>%
    .$gh_link
  out <- purrr::map_df(req, open_apc_get_)
  inner_join(out, open_apc_collections(), by = "gh_link")
}
#' Get single Open APC dataset using GitHub Data API
#'
#' @param gh_link URL to GitHub blob
#'
#' @importFrom readr read_csv
#' @importFrom dplyr select mutate
#' @importFrom tidyselect any_of
#'
#' @export
open_apc_get_ <- function(gh_link = NULL) {
  gh_file(gh_link, to_disk = FALSE) %>%
    read_csv() %>%
    select(any_of(c("institution", "doi", "period", "euro", "is_hybrid", "agreement"))) %>%
    mutate(gh_link = gh_link)
}

#' Open APC collections
#'
#' @importFrom tibble tribble
#' @export
open_apc_collections <- function() {
  tibble::tribble(
    ~open_apc_collection, ~gh_link,
    "main", "https://github.com/OpenAPC/openapc-de/blob/master/data/apc_de.csv",
    "co-funding", "https://github.com/OpenAPC/openapc-de/blob/master/data/apc_cofunding.csv",
    "transformative agreements", "https://github.com/OpenAPC/openapc-de/blob/master/data/transformative_agreements/transformative_agreements.csv",
    "deal-wiley-optout", "https://github.com/OpenAPC/openapc-de/blob/master/data/transformative_agreements/deal_wiley_germany_opt_out/deal_wiley_germany_opt_out.csv"
  )
}
#' Gets a file from a github repo, using the Data API blob endpoint
#'
#' This avoids the 1MB limit of the content API and uses [gh::gh] to deal with
#' authorization and such.  See https://developer.github.com/v3/git/blobs/
#'
#' @author Noam Ross
#'
#' @param url the URL of the file to download via API, of the form
#'   `github.com/:owner/:repo/blob/:path
#' @param ref the reference of a commit: a branch name, tag, or commit SHA
#' @param owner,repo,path,ref alternate way to specify the file.  These will
#'   override values in `url`
#' @param to_disk,destfile write file to disk (default=TRUE)?  If so, use the
#'   name in `destfile`, or the original filename by default
#' @param .token,.api_url,.method,.limit,.send_headers arguments passed on to
#'   [gh::gh]
#' @importFrom gh gh
#' @importFrom stringi stri_match_all_regex
#' @importFrom purrr %||% keep
#' @importFrom base64enc  base64decode
#' @return Either the local path of the downloaded file (default), or a raw
#'   vector
gh_file <- function(url = NULL, ref=NULL,
                    owner = NULL, repo = NULL, path = NULL,
                    to_disk=TRUE, destfile=NULL,
                    .token = NULL, .api_url= NULL, .method="GET",
                    .limit = NULL, .send_headers = NULL) {
  if (!is.null(url)) {
    matches <- stri_match_all_regex(
      url,
      "(github\\.com/)?([^\\/]+)/([^\\/]+)/[^\\/]+/([^\\/]+)/([^\\?]+)"
    )
    owner <- owner %||% matches[[1]][3]
    repo <- repo %||% matches[[1]][4]
    ref <- ref %||% matches[[1]][5]
    path <- path %||% matches[[1]][6]
    pathdir <- dirname(path)
    pathfile <- basename(path)
  }

  dir_contents <- gh(
    "/repos/:owner/:repo/contents/:path",
    owner = owner, repo = repo, path = pathdir, ref = ref,
    .token = NULL, .api_url = NULL, .method = "GET",
    .limit = NULL, .send_headers = NULL
  )
  file_sha <- keep(dir_contents, ~ .$path == path)[[1]]$sha
  blob <- gh(
    "/repos/:owner/:repo/git/blobs/:sha",
    owner = owner, repo = repo, sha = file_sha,
    .token = NULL, .api_url = NULL, .method = "GET",
    .limit = NULL, .send_headers = NULL
  )
  raw <- base64decode(blob[["content"]])
  if (to_disk) {
    destfile <- destfile %||% pathfile
    writeBin(raw, con = destfile)
    return(destfile)
  } else {
    return(raw)
  }
}
