type id = string

type t = {
  id: id,
  name: string,
}

let id = t => t.id

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
  }
}
