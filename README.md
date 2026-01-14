# obsws


<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

A simple R client for the [OBS WebSocket
server](https://github.com/obsproject/obs-websocket) based on
[R6](https://r6.r-lib.org/) and
[websocket](https://github.com/rstudio/websocket) packages.

## Usage

This package relies on the websocket package, which requires an
interactive R session (or a running event loop). Code examples in this
README are illustrative and may not run in non-interactive contexts such
as RMarkdown or Quarto.

``` r
# NOTE: This snippet must be run within the 'global loop',
#   i.e. in an interactive R session due to the limitations of the websocket package.
#   See also
#     * <https://github.com/rstudio/websocket/issues/52>
#     * <https://github.com/rstudio/websocket/issues/53>
pkgload::load_all(export_all = FALSE)
dotenv::load_dot_env(".env")

data(ReqType)
data(EventSub)

client <- Client$new(url = paste0("ws://", Sys.getenv("OBS_HOST"), ":4455"))
client$connect(password = Sys.getenv("OBS_PASSWORD"))
client$reidentify(bitwOr(EventSub$General, EventSub$Ui))

if (client$current_state() == "identified") {
  req_id <- client$emit(ReqType$GetVersion, NULL)
  resp <- waiter_for_response(10)(client, req_id)
  d <- parse_data(resp)
}

if (!is.null(d)) {
  saveRDS(d, file = "tools/obs_get-version.rds")
}

client$disconnect(reset = TRUE)
rm(client)
```

This `d` object is a parsed response to the ‘GetVersion’ request. It is
something like this:

``` r
d <- readRDS("tools/obs_get-version.rds")
str(d)
#> List of 1
#>  $ :List of 4
#>   ..$ requestId    : chr "ICR8aaPFEQZE-000000001"
#>   ..$ requestStatus:List of 2
#>   .. ..$ code  : int 100
#>   .. ..$ result: logi TRUE
#>   ..$ requestType  : chr "GetVersion"
#>   ..$ responseData :List of 7
#>   .. ..$ availableRequests    : chr [1:150] "GetHotkeyList" "OpenInputInteractDialog" "SaveSourceScreenshot" "GetVersion" ...
#>   .. ..$ obsVersion           : chr "32.0.4"
#>   .. ..$ obsWebSocketVersion  : chr "5.6.3"
#>   .. ..$ platform             : chr "windows"
#>   .. ..$ platformDescription  : chr "Windows 11 Version 25H2"
#>   .. ..$ rpcVersion           : int 1
#>   .. ..$ supportedImageFormats: chr [1:17] "bmp" "cur" "icns" "ico" ...
```

## License

MIT License.
