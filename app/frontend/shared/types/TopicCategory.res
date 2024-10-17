type t = {
  id: string,
  name: string,
}

let id = t => t.id

let name = t => t.name

@scope("JSON") @val
external parse: string => t = "parse"

let color = t => StringUtils.toColor(t.name)
