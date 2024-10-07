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
    name: field("name", string, json),
    endsAt: option(field("endsAt", string), json)->Belt.Option.map(DateFns.parseISO),
  }
}
