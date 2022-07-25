exception DataElementMissing(string)

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
  | _ =>
    let message = "Unable to find env with key " ++ envString
    Rollbar.error(message)
    raise(DataElementMissing(message))
  }

let env = () =>
  switch document |> Document.documentElement |> Element.getAttribute("data-env") {
  | Some(props) => decode(props)
  | None =>
    let message = "Unable to find data env at envUtils "
    Rollbar.error(message)
    raise(DataElementMissing(message))
  }

let isDevelopment = () => env() == Development
let isTest = () => env() == Test
