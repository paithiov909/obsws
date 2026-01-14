# NOTE: This snippet must be run within the 'global loop',
#   i.e. in an interactive R session due to the limitations of the websocket package.
#   See also
#     * <https://github.com/rstudio/websocket/issues/52>
#     * <https://github.com/rstudio/websocket/issues/53>
pkgload::load_all(export_all = FALSE)
dotenv::load_dot_env(".env")

data(ReqType)

client <- Client$new(url = paste0("ws://", Sys.getenv("OBS_HOST"), ":4455"))
client$connect(password = Sys.getenv("OBS_PASSWORD"))

if (client$current_state() == "identified") {
  req_id <- client$emit(ReqType$GetVersion, NULL)
  resp <- waiter_for_response(10)(client, req_id)
  d <- parse_data(resp)
}

if (!is.null(d)) {
  saveRDS(d, file = "inst/extdata/obs_get-version.rds")
}

client$disconnect(reset = TRUE)
rm(client)
