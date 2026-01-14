messages <- c(
  '{"op": 0,
    "d": {
      "obsStudioVersion": "30.2.2",
      "obsWebSocketVersion": "5.5.2",
      "rpcVersion": 1,
      "authentication": {
        "challenge": "+IxH4CnCiqpX1rM9scsNynZzbOe4KhDeYcTNS3PDaeY=",
        "salt": "lM1GncleQOaCu9lT1yeUZhFYnqhsLLP1G5lAGo3ixaI="
      }
    }}',
  '{"op": 0,
    "d": {
      "obsStudioVersion": "30.2.2",
      "obsWebSocketVersion": "5.5.2",
      "rpcVersion": 1
    }}',
  '{"op": 2,
    "d": {
      "negotiatedRpcVersion": 1
    }}',
  '{"op": 5,
    "d": {
      "eventType": "StudioModeStateChanged",
      "eventIntent": 1,
      "eventData": {
        "studioModeEnabled": true
      }
    }}',
  '{"op": 7,
    "d": {
      "requestType": "SetCurrentProgramScene",
      "requestId": "f819dcf0-89cc-11eb-8f0e-382c4ac93b9c",
      "requestStatus": {
        "result": true,
        "code": 100
      }
    }}',
  '{"op": 7,
    "d": {
      "requestType": "SetCurrentProgramScene",
      "requestId": "f819dcf0-89cc-11eb-8f0e-382c4ac93b9c",
      "requestStatus": {
        "result": false,
        "code": 608,
        "comment": "Parameter: sceneName"
      }
    }
  }',
  '{"d": {
      "requestType": "SetCurrentProgramScene",
      "requestId": "f819dcf0-89cc-11eb-8f0e-382c4ac93b9c",
      "requestStatus": {
        "result": false,
        "code": 608,
        "comment": "Parameter: sceneName"
      }
    },
    "op": 7
  }'
)

test_that("parse_messages works", {
  expect_snapshot_value(
    parse_message(messages),
    style = "json2",
    cran = FALSE
  )
  expect_snapshot_value(
    parse_message(messages, only = c(1L))[[1]][["d"]],
    style = "json2",
    cran = FALSE
  )
})

test_that("parse_op works", {
  expect_snapshot_value(
    parse_op(messages),
    style = "json2",
    cran = FALSE
  )
  expect_type(parse_op(messages), "integer")
  expect_type(parse_op(messages[1]), "integer")
})

test_that("parse_data works", {
  expect_snapshot_value(
    parse_data(messages),
    style = "json2",
    cran = FALSE
  )
  expect_snapshot_value(
    parse_data(messages, only = c(1L)),
    style = "json2",
    cran = FALSE
  )
})

test_that("parse_event_type works", {
  expect_snapshot_value(
    parse_event_type(messages),
    style = "json2",
    cran = FALSE
  )
  expect_type(parse_event_type(messages), "character")
  expect_type(parse_event_type(messages[1]), "character")
})

test_that("parse_request_id works", {
  expect_snapshot_value(
    parse_request_id(messages),
    style = "json2",
    cran = FALSE
  )
  expect_type(parse_request_id(messages), "character")
  expect_type(parse_request_id(messages[1]), "character")
})

test_that("parse_result works", {
  expect_snapshot_value(
    parse_result(messages),
    style = "json2",
    cran = FALSE
  )
  expect_type(parse_result(messages), "logical")
  expect_type(parse_result(messages[1]), "logical")
})
