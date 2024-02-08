type t = {
  id: string,
  name: string,
  isAdmin: bool,
  isAuthor: bool,
  isCoach: bool,
}

let id = t => t.id
let name = t => t.name
let isAdmin = t => t.isAdmin
let isAuthor = t => t.isAuthor
let isCoach = t => t.isCoach

let isModerator = t => t.isAdmin || t.isAuthor || t.isCoach

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    isAdmin: field("isAdmin", bool, json),
    isAuthor: field("isAdmin", bool, json),
    isCoach: field("isAdmin", bool, json),
  }
}
