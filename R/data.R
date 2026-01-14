#' Enums from the OBS WebSocket protocol
#'
#' See [obs-websocket/docs/generated/protocol.md](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#enums)
#'
#' @source
#' <https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.json>
#' @family obsws-data
"obs_enums"

#' Events from the OBS WebSocket protocol
#'
#' See [obs-websocket/docs/generated/protocol.md](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#events)
#'
#' @source
#' <https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.json>
#' @family obsws-data
"obs_events"

#' Requests from the OBS WebSocket protocol
#'
#' See [obs-websocket/docs/generated/protocol.md](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#requests)
#'
#' @source
#' <https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.json>
#' @family obsws-data
"obs_requests"

#' All request types from the OBS WebSocket protocol
#'
#' @source
#' <https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.json>
#' @family obsws-data
"ReqType"

# use_request_type <- function(env = parent.frame()) {
#   assign(
#     "reqtype",
#     rlang::as_environment(obs_reqtype),  #nolint
#     envir = env
#   )
#   invisible(NULL)
# }
