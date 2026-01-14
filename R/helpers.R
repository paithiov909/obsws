as_state <- function(x) {
  factor(
    x,
    levels = 1:4,
    labels = c("fresh", "connecting", "identified", "closed")
  )
}

as_tibble <- function(x) {
  structure(x, class = c("tbl_df", "tbl", "data.frame"))
}

#' Solve authentication challenge
#'
#' @param auth_field Authentication field
#' @param password Password
#' @returns A string
#' @noRd
gen_auth <- function(auth_field, password) {
  password <- paste0(password, auth_field$salt)
  b64secret <- secretbase::base64enc(
    secretbase::sha256(charToRaw(password), convert = FALSE),
    convert = TRUE
  )
  challenge <- paste0(b64secret, auth_field$challenge)
  authentication <- secretbase::base64enc(
    secretbase::sha256(charToRaw(challenge), convert = FALSE),
    convert = TRUE
  )
  authentication
}

#' `jsonlite::toJSON` with `auto_unbox = TRUE`
#' @noRd
to_json <- function(x) {
  jsonlite::toJSON(x, auto_unbox = TRUE)
}

#' Generate random IDs
#'
#' @param n Number of IDs to generate
#' @param length Length of each ID
#' @returns A character vector
#' @export
#' @keywords internal
rand_id <- function(n, length = 12) {
  chrs <- c(letters, LETTERS, 0:9)
  sample(chrs, length * n, replace = TRUE) |>
    split(factor(seq_len(n))) |>
    lapply(function(s) paste0(s, collapse = "")) |>
    unlist(use.names = FALSE)
}
