open Webapi.Dom

type t = {
  name: string,
  email: string,
}

let name = t => t.name
let email = t => t.email

let decodeUser = json => {
  open Json.Decode
  {
    name: json |> field("name", string),
    email: json |> field("email", string),
  }
}

let current = () =>
  switch document |> Document.documentElement |> Element.getAttribute("data-user") {
  | Some(props) => Some(props |> Json.parseOrRaise |> decodeUser)
  | None => None
  }
