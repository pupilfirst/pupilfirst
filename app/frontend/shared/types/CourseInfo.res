type id = string

type t = {
  id: id,
  name: string,
  endsAt: option<Js.Date.t>,
}

let id = t => t.id
let name = t => t.name
let endsAt = t => t.endsAt
let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    name: json |> field("name", string),
    endsAt: (json |> optional(field("endsAt", string)))->Belt.Option.map(DateFns.parseISO),
  }
}
