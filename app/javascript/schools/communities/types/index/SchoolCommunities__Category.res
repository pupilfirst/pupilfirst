type t = {
  id: string,
  name: string,
  topicsCount: int,
}

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    topicsCount: json |> field("topicsCount", int),
  }
}

let id = t => t.id

let name = t => t.name

let topicsCount = t => t.topicsCount

let updateName = (name, t) => {
  ...t,
  name: name,
}

let make = (~id, ~name, ~topicsCount) => {id: id, name: name, topicsCount: topicsCount}

let makeFromJs = data => {
  id: data["id"],
  name: data["name"],
  topicsCount: data["topicsCount"],
}

let color = t => StringUtils.toColor(t.name)
