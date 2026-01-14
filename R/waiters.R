#' Wait for messages
#'
#' @description
#' Waits for messages from the OBS websocket server
#' until a timeout is reached.
#'
#' This is useful for forcing to update the message queue of a client.
#' Since the message queue is updated asynchronously
#' within an event loop of the [later] package,
#' you need to update the queue manually where the R session keeps busy.
#'
#' @param timeout Maximum time to wait for messages.
#' @returns Called for side effects.
#' @export
wait_for_messages <- function(timeout = 1) {
  t0 <- Sys.time()
  repeat {
    later::run_now(0)
    if (difftime(Sys.time(), t0, units = "secs") > timeout) {
      break
    }
    Sys.sleep(0.05)
  }
  invisible(NULL)
}

#' Generate waiter for RequestResponse messages
#'
#' @param max_retries Maximum number of retries.
#' @param interval Interval between retries.
#' @param error_on_timeout Whether to throw an error if no response is received.
#' @returns
#'  A function that takes a `Client` and request ID as arguments
#'  and returns the response message as a JSON string from the queue.
#' @export
waiter_for_response <- function(
  max_retries = 10,
  interval = 1,
  error_on_timeout = TRUE
) {
  function(client, request_id) {
    for (retry in seq_len(max_retries)) {
      wait_for_messages(interval)
      events <- client$pluck(reset = FALSE)
      if (!rlang::is_empty(events)) {
        request <- parse_request_id(events) == request_id
        if (any(request)) {
          target <- events[request]
          return(target[!is.na(target)])
        }
      }
    }
    if (error_on_timeout) {
      cli::cli_abort("Could not get any responses for request {request_id}")
    }
    NA_character_
  }
}
