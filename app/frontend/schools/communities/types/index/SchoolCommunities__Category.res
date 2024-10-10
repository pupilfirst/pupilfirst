type t = {
  id: string,
  name: string,
  topicsCount: int,
}

@scope("JSON") @val
external parse: string => t = "parse"

let id = t => t.id

let name = t => t.name

let topicsCount = t => t.topicsCount

let updateName = (name, t) => {
  ...t,
  name,
}

let make = (~id, ~name, ~topicsCount) => {id, name, topicsCount}

let color = t => StringUtils.toColor(t.name)
