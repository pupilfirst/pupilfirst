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
  | JsonUtils.Object(dict) => {
      let endsAt = switch dict->Dict.get("endsAt") {
      | Some(String(endsAtString)) => DateFns.parseISO(endsAtString)->Some
      | Some(JsonUtils.Null) => None
      | _ => raise(JsonUtils.DecodeError("Invalid endsAt supplied to CourseInfo.decode"))
      }

      switch (dict->Dict.get("id"), dict->Dict.get("name")) {
      | (Some(String(id)), Some(String(name))) => {
          id,
          name,
          endsAt,
        }
      | _ =>
        raise(JsonUtils.DecodeError("JSON supplied to CourseInfo.decode was in unexpected shape"))
      }
    }
  | _ => raise(JsonUtils.DecodeError("Invalid JSON supplied to CourseInfo.decode"))
  }
