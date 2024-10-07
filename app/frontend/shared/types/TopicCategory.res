type t = {
  id: string,
  name: string,
}

let id = t => t.id

let name = t => t.name

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    name: field("name", string, json),
  }
}

let color = t => StringUtils.toColor(t.name)
