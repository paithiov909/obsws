#' Parse messages from the OBS WebSocket server
#'
#' @description
#' These functions parse JSON messages from the OBS WebSocket server.
#' They are wrappers around [RcppSimdJson::fparse()].
#'
#' @param jsonl A character vector of JSON messages.
#' @param only Indices of messages to parse.
#'  If missing, all messages in `jsonl` are parsed.
#' @param query Query to be passed to [RcppSimdJson::fparse()].
#'  Defaults to `"/d"`.
#' @returns
#'  * For `parse_message()`, a list of parsed messages.
#'  * For `parse_op()`, an integer vector of parsed '/op' fields.
#'  * For `parse_data()`, a list of parsed fields.
#'  * For `parse_event_type()`, a character vector of parsed '/d/eventType' fields.
#'  * For `parse_request_id()`, a character vector of parsed '/d/requestId' fields.
#'  * For `parse_result()`, a logical vector of parsed '/d/requestStatus/result' fields.
#' @rdname parser
#' @name parser
NULL

#' @rdname parser
#' @export
parse_message <- function(jsonl, only) {
  if (!missing(only)) {
    jsonl <- jsonl[only]
  }
  RcppSimdJson::fparse(jsonl, max_simplify_lvl = "vector", always_list = TRUE)
}

#' @rdname parser
#' @export
parse_op <- function(jsonl, only) {
  if (!missing(only)) {
    jsonl <- jsonl[only]
  }
  ret <- RcppSimdJson::fparse(
    jsonl,
    query = "/op",
    parse_error_ok = TRUE,
    on_parse_error = NA_integer_,
    query_error_ok = TRUE,
    on_query_error = NA_integer_,
    max_simplify_lvl = "vector",
    type_policy = "numbers",
    always_list = TRUE
  )
  # integer
  unlist(ret, use.names = FALSE)
}

#' @rdname parser
#' @export
parse_data <- function(jsonl, only, query = "/d") {
  if (!missing(only)) {
    jsonl <- jsonl[only]
  }
  RcppSimdJson::fparse(
    jsonl,
    query = query,
    query_error_ok = TRUE,
    on_query_error = NULL,
    parse_error_ok = TRUE,
    on_parse_error = NULL,
    max_simplify_lvl = "vector",
    type_policy = "anything_goes",
    always_list = TRUE
  )
}

#' @rdname parser
#' @export
parse_event_type <- function(jsonl, only) {
  if (!missing(only)) {
    jsonl <- jsonl[only]
  }
  ret <- RcppSimdJson::fparse(
    jsonl,
    query = "/d/eventType",
    query_error_ok = TRUE,
    on_query_error = NA_character_,
    parse_error_ok = TRUE,
    on_parse_error = NA_character_,
    max_simplify_lvl = "vector",
    type_policy = "strict",
    always_list = TRUE
  )
  # character
  unlist(ret, use.names = FALSE)
}

#' @rdname parser
#' @export
parse_request_id <- function(jsonl, only) {
  if (!missing(only)) {
    jsonl <- jsonl[only]
  }
  ret <- RcppSimdJson::fparse(
    jsonl,
    query = "/d/requestId",
    query_error_ok = TRUE,
    on_query_error = NA_character_,
    parse_error_ok = TRUE,
    on_parse_error = NA_character_,
    max_simplify_lvl = "vector",
    type_policy = "strict",
    always_list = TRUE
  )
  # character
  unlist(ret, use.names = FALSE)
}

#' @rdname parser
#' @export
parse_result <- function(jsonl, only) {
  if (!missing(only)) {
    jsonl <- jsonl[only]
  }
  ret <- RcppSimdJson::fparse(
    jsonl,
    query = "/d/requestStatus/result",
    query_error_ok = TRUE,
    on_query_error = NA,
    parse_error_ok = TRUE,
    on_parse_error = NA,
    max_simplify_lvl = "vector",
    type_policy = "strict",
    always_list = TRUE
  )
  # logical
  unlist(ret, use.names = FALSE)
}
