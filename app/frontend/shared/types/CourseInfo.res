type id = string

type t = {
  id: id,
  name: string,
  endsAt: option<Js.Date.t>,
}

let id = t => t.id
let name = t => t.name
let endsAt = t => t.endsAt

let decode = json =>
  switch json {
  | JsonUtils.Object(dict) =>
    let endsAt = JsonUtils.parseTimestamp(dict, "endsAt", "CourseInfo.decode")

    {
      id: dict->Dict.getUnsafe("id"),
      name: dict->Dict.getUnsafe("name"),
      endsAt,
    }
  | _ => raise(JsonUtils.DecodeError("Invalid JSON supplied to CourseInfo.decode"))
  }
