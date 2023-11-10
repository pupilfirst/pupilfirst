type t = {
  id: string,
  name: string,
  maxGrade: int,
}

let id = t => t.id

let name = t => t.name

let make = (~id, ~name, ~maxGrade) => {
  id: id,
  name: name,
  maxGrade: maxGrade,
}

let makeFromJs = ecData =>
  ecData |> Js.Array.map(ec => make(~id=ec["id"], ~name=ec["name"], ~maxGrade=ec["maxGrade"]))
