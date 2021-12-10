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

let status = t => t.status

let description = t => t.description
