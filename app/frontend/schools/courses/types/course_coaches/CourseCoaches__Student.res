type t = {
  id: string,
  name: string,
}

let name = t => t.name
let id = t => t.id

let make = (~id, ~name) => {
  id,
  name,
}
