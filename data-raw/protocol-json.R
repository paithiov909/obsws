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
