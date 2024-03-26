type t = {
  id: string,
  levelId: string,
  name: string,
  description: string,
  sortIndex: int,
}

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    levelId: json |> field("levelId", string),
    name: json |> field("name", string),
    description: json |> field("description", string),
    sortIndex: json |> field("sortIndex", int),
  }
}

let sort = targetGroups =>
  targetGroups |> ArrayUtils.copyAndSort((x, y) => x.sortIndex - y.sortIndex)

let id = t => t.id
let name = t => t.name
let levelId = t => t.levelId
let description = t => t.description
