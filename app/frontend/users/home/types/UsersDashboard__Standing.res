type t = {
  name: string,
  color: string,
}

let name = t => t.name
let color = t => t.color

let decode = json => {
  open Json.Decode
  {
    name: field("name", string, json),
    color: field("color", string, json),
  }
}
