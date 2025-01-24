open Webapi.Dom

type env =
  | Development
  | Test
  | Production

let decode = envString =>
  switch envString {
  | "development" => Development
  | "test" => Test
  | "production" => Production
  | _ => Js.Exn.raiseError("EnvUtils.decode failed to decode env: " ++ envString)
  }

let env = () =>
  switch document->Document.documentElement->Element.getAttribute("data-env") {
  | Some(props) => decode(props)
  | None => Js.Exn.raiseError("EnvUtils.env could not find data-env")
  }

let isDevelopment = () => env() == Development
let isTest = () => env() == Test
