exception UnknownStatus(string)

type status = [#success | #failure | #pending | #error]

type t = {
  id: string,
  status: status,
  description: string,
}

let makeFromJS = object => {
  {
    id: object["id"],
    description: object["description"],
    status: object["status"],
  }
}

let make = (~id, ~status, ~description) => {
  id: id,
  status: status,
  description: description,
}

let id = t => t.id

let status = t => t.status

let description = t => t.description
