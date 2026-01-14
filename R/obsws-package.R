#' @keywords internal
"_PACKAGE"

#' R6 class for OBS WebSocket client
#'
#' @description
#' An R6 class for OBS WebSocket server client.
#'
#' @importFrom R6 R6Class
#' @importFrom fastmap fastqueue
#' @importFrom websocket WebSocket
#' @import cli
#' @export
Client <- R6::R6Class( #nolint
  "OBSClient",
  public = list(
    #' @description
    #' Creates a new OBSClient object.
    #' @param url URL of an OBS WebSocket server.
    #' @param id Client ID (used as prefix for request IDs).
    #' @returns
    #' `new(Client)` returns a new OBSClient object.
    initialize = function(url = "ws://localhost:4455", id = rand_id(1)) {
      if (!is.character(id) || length(id) != 1 || anyNA(id)) {
        cli::cli_abort("`id` must be a string scalar")
      }
      private$id <- id
      private$counter <- 0
      private$queue <- fastmap::fastqueue(missing_default = character(0))
      private$ws <-
        websocket::WebSocket$new(
          url = url,
          protocols = "obswebsocket.json",
          autoConnect = FALSE,
          accessLogChannels = "none",
          errorLogChannels = "none"
        )
      private$ws$onClose(function(event) {
        private$state <- as_state(4)
      })
      private$ws$onError(function(event) {
        private$state <- as_state(4)
      })
      private$ws$onMessage(function(event) {
        private$queue$add(event$data)
      })
      private$state <- as_state(1)
    },
    #' @description
    #' Connects to an OBS WebSocket server.
    #' Note that this method behaves synchronously (blocks the R session)
    #' so as to wait for the identified message from the server.
    #' @param password Password for authentication.
    #' @param max_retries Maximum number of retries.
    #' @param interval Interval between retries.
    #' @param verbose Whether to print messages.
    connect = function(
      password,
      max_retries = 10,
      interval = 1,
      verbose = TRUE
    ) {
      if (self$current_state() == "fresh") {
        private$ws$connect()
        private$state <- as_state(2)
        wait_for_messages(interval)
      }
      if (self$current_state() != "connecting") {
        cli::cli_abort("Client state is {self$current_state()}; not connecting")
      }

      # Take Hello (OpCode 0) from queue
      msgs <- self$pluck(reset = FALSE)
      hello <- parse_op(msgs) == 0L
      if (rlang::is_empty(msgs) || !any(hello)) {
        cli::cli_abort("There are no Hello messages in queue")
      }
      hello_msgs <- parse_data(msgs, only = hello)
      auth_field <- hello_msgs[[length(hello_msgs)]]$authentication

      tryCatch(
        {
          # Send Identify (OpCode 1)
          if (!is.null(auth_field)) {
            msg <- to_json(
              list(
                op = 1,
                d = list(
                  rpcVersion = 1,
                  authentication = gen_auth(auth_field, password)
                )
              )
            )
            private$ws$send(msg)
          } else {
            msg <- to_json(list(op = 1, d = list(rpcVersion = 1)))
            private$ws$send(msg)
          }

          # Wait for Identified (OpCode 2)
          for (retry in seq_len(max_retries)) {
            wait_for_messages(interval)
            events <- self$pluck(reset = FALSE)
            if (!rlang::is_empty(events)) {
              identified <- parse_op(events) == 2L
              if (any(identified)) {
                private$state <- as_state(3)
                break
              }
            }
            if (verbose) {
              cli::cli_inform(
                "Waiting for identified message: ({retry}/{max_retries})"
              )
            }
          }
          if (self$current_state() != "identified") {
            stop("Failed to get identified message")
          }
        },
        error = function(e) {
          self$disconnect()
          cli::cli_abort(
            "Failed to connect to OBS websocket server"
          )
        }
      )
      invisible(self)
    },
    #' @description
    #' Disconnects from the OBS WebSocket server.
    #' @param reset Whether to reset message queue after disconnect.
    disconnect = function(reset = FALSE) {
      if (self$ready_state() %in% c(0L, 1L)) {
        private$ws$close()
      }
      if (reset) {
        self$reset()
      }
      private$state <- as_state(4)
      invisible(self)
    },
    #' @description
    #' Resets message queue.
    reset = function() {
      private$queue$reset()
      invisible(self)
    },
    #' @description
    #' Gets messages from queue as a character vector.
    #' @param only Indices of messages to pluck.
    #'  If missing, all messages are plucked.
    #' @param reset Whether to reset queue after pluck.
    #' @returns
    #' `clients$pluck()` returns JSON strings representing recieved messages.
    pluck = function(only, reset = FALSE) {
      msgs <-
        unlist(private$queue$as_list(), use.names = FALSE) |>
        as.character()
      if (reset) {
        self$reset()
      }
      if (missing(only)) {
        return(msgs)
      }
      msgs[only]
    },
    #' @description
    #' Sends a request to OBS.
    #' @param type A string representing request type.
    #' @param data A list of request data.
    #' @returns
    #' `client$emit()` returns corresponding request ID sent to OBS.
    emit = function(type, data = NULL) {
      req_id <- private$gen_request_id()
      msg <- to_json(list(
        op = 6,
        d = list(requestType = type, requestId = req_id, requestData = data)
      ))
      private$ws$send(msg)
      req_id
    },
    #' @description
    #' Reidentifies with event subscriptions.
    #' @param subscriptions An integer scalar
    #'  representing event subscriptions bitmask.
    reidentify = function(subscriptions = NULL) {
      msg <-
        to_json(list(
          op = 3,
          d = list(
            eventSubscriptions = as.integer(subscriptions)
          )
        ))
      private$ws$send(msg)
      invisible(self)
    },
    #' @description
    #' Gets current client state.
    #' @returns
    #' `client$current_state()` returns current state of the client.
    current_state = function() {
      private$state
    },
    #' @description
    #' Gets current WebSocket ready state.
    #' @returns
    #' `client$ready_state()` returns current WebSocket ready state.
    ready_state = function() {
      private$ws$readyState()
    }
  ),
  private = list(
    finalize = function() {
      self$disconnect()
    },
    # Client ID
    id = NULL,
    # Current state; 1: fresh, 2: connecting, 3: identified, 4: closed
    state = NULL,
    # WebSocket object
    ws = NULL,
    # Message queue
    queue = NULL,
    # Generate request ID
    gen_request_id = function(name = paste(private$id, "%09d", sep = "-")) {
      private$counter <- private$counter + 1
      sprintf(name, private$counter)
    },
    counter = NULL
  )
)
