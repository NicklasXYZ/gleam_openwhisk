import gleam/bit_builder
import gleam/http.{Post}
import gleam/http/elli
import gleam/http/middleware
import gleam_openwhisk/web/logger
import function

// This function implements the OpenWhisk 'Action interface'  used to integrate with
// the OpenWhisk platform. The 'Action interface' performs the following:
// 1. Initialization through a POST request to localhost:8080/init with JSON data:
// {
//   "value": {
//     "name" : String,
//     "main" : String,
//     "code" : String,
//     "binary": Boolean,
//     "env": Map[String, String]
//   }
// }
// --> localhost:8080/init should respond with status 200 OK, otherwise it is a failure
//
// 2. Function activation through a POST request to localhost:8080/run with JSON data:
// {
//   // Here the field "value", below, is a JSON object and contains all the parameters
//   // for the function activation.
//   "value": JSON,
//   "namespace": String,
//   "action_name": String,
//   "api_host": String,
//   "api_key": String,
//   "activation_id": String,
//   "transaction_id": String,
//   "deadline": Number
// }
// --> localhost:8080/run should respond with status 200 OK, otherwise it is a failure
// For more information see:
// https://github.com/apache/openwhisk/blob/master/docs/actions-new.md#action-interface
pub fn service(req) {
  let path = http.path_segments(req)

  case req.method, path {
    Post, ["init"] -> function.init(req)
    Post, ["run"] -> function.run(req)
  }
}

pub fn start() {
  let service =
    service
    |> middleware.prepend_resp_header("made-with", "Gleam")
    |> middleware.map_resp_body(bit_builder.from_bit_string)
    |> logger.middleware

  elli.start(service, on_port: 8080)
}
