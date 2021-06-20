import gleam/http.{Request, Response}
import gleam/io
import gleam/jsone
import gleam/result
import gleam/bit_string
import gleam/bit_builder
import decode
import gleam/string

// 1. This function performs function environment initialization. This function is
// run when a POST request is sent to localhost:8080/init by the OpenWhisk platform. 
pub fn init(req) {
  let Ok(status) =
    jsone.object([#("status", jsone.string("Everything is fine!"))])
    |> jsone.encode
    |> result.then(decode.decode_dynamic(_, decode.bit_string()))
  http.response(200)
  |> http.set_resp_body(status)
  |> http.prepend_resp_header("content-type", "application/json")
}

// 2. This is where the serverless function invocation happens. This function is run
// when a POST request is sent to localhost:8080/run by the OpenWhisk platform.
// Replace the current 'test_function()' below with your own function: 
pub fn run(req: Request(BitString)) {
  let json_data =
    req.body
    |> test_function()
  http.response(200)
  |> http.prepend_resp_header("content-type", "application/json")
  |> http.set_resp_body(json_data)
}

// THE CODE BELOW IS FOR ILLUSTRATIONAL AND TESTING PURPOSES ONLY.
// YOU SHOULD IMPLEMENT YOUR OWN FUNCTION LOGIC HERE BELOW!
fn test_function(data) {
  // Decode the JSON data that we received from the entity that invoked the function
  let decoded_data = decode_data_test_function(data)
  // Encode JSON data that we will return to the entity that invoked the function
  encode_data_test_function(decoded_data)
}

// Define types 'ValueObject' and 'Values' that are used to decode JSON data of the 
// following form:
// {
//    "value": {
//      "name": "Some name here"
//    }
// } 
type ValuesObject {
  ValuesObject(name: String)
}

type Values {
  Values(value: ValuesObject)
}

fn decode_data_test_function(data) {
  let json_object_decoder =
    decode.map(ValuesObject, decode.field("name", decode.string()))
  let json_decoder =
    decode.map(Values, decode.field("value", json_object_decoder))

  // Convert BitString to String
  let Ok(string_data) =
    data
    |> bit_string.to_string()

  // Convert String to Gleam types
  let decoded_data =
    string_data
    |> jsone.decode
    |> result.then(decode.decode_dynamic(_, json_decoder))
  case decoded_data {
    Ok(values) -> values
    _ -> Values(value: ValuesObject(name: "there"))
  }
}

fn encode_data_test_function(data) {
  // Create some JSON return data for illustration & testing purposes 
  let Ok(encoded_data) =
    jsone.object([
      #("int_field", jsone.int(42)),
      #(
        "string_field",
        jsone.string(string.concat([
          "Hello ",
          data.value.name,
          ", from Gleam & OpenWhisk!",
        ])),
      ),
    ])
    |> jsone.encode
    |> result.then(decode.decode_dynamic(_, decode.bit_string()))
  encoded_data
}
