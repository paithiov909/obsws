url <-
  "https://github.com/obsproject/obs-websocket/raw/refs/tags/5.6.3/docs/generated/protocol.json"

json <- RcppSimdJson::fload(url, alyway_list = TRUE)

names(json)

obs_enums <- dplyr::as_tibble(json[["enums"]])
obs_requests <- dplyr::as_tibble(json[["requests"]])
obs_events <- dplyr::as_tibble(json[["events"]])
ReqType <-
  rlang::set_names(obs_requests[["requestType"]], obs_requests[["requestType"]]) |>
  as.list()

usethis::use_data(obs_enums, obs_requests, obs_events, ReqType, overwrite = TRUE)


# Event subscription bitmask values for obs-websocket 5.x
# Generated from obs-websocket protocol specification
EventSub <-
  list(
    None = 0L,
    General = bitwShiftL(1L, 0),
    Config = bitwShiftL(1L, 1),
    Scenes = bitwShiftL(1L, 2),
    Inputs = bitwShiftL(1L, 3),
    Transitions = bitwShiftL(1L, 4),
    Filters = bitwShiftL(1L, 5),
    Outputs = bitwShiftL(1L, 6),
    SceneItems = bitwShiftL(1L, 7),
    MediaInputs = bitwShiftL(1L, 8),
    Vendors = bitwShiftL(1L, 9),
    Ui = bitwShiftL(1L, 10),

    # Helper: all non-high-volume events
    All = Reduce(
      bitwOr,
      c(
        bitwShiftL(1L, 0), # General
        bitwShiftL(1L, 1), # Config
        bitwShiftL(1L, 2), # Scenes
        bitwShiftL(1L, 3), # Inputs
        bitwShiftL(1L, 4), # Transitions
        bitwShiftL(1L, 5), # Filters
        bitwShiftL(1L, 6), # Outputs
        bitwShiftL(1L, 7), # SceneItems
        bitwShiftL(1L, 8), # MediaInputs
        bitwShiftL(1L, 9), # Vendors
        bitwShiftL(1L, 10) # Ui
      ),
      init = 0L
    ),

    # High-volume events
    InputVolumeMeters = bitwShiftL(1L, 16),
    InputActiveStateChanged = bitwShiftL(1L, 17),
    InputShowStateChanged = bitwShiftL(1L, 18),
    SceneItemTransformChanged = bitwShiftL(1L, 19)
  )

usethis::use_data(EventSub, overwrite = TRUE)
