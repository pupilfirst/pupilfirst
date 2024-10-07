type t = {
  id: string,
  name: string,
  email: string,
  avatarUrl: option<string>,
  title: string,
}

let name = t => t.name

let email = t => t.email

let id = t => t.id

let avatarUrl = t => t.avatarUrl

let title = t => t.title

let decode = json => {
  open Json.Decode
  {
    name: field("name", string, json),
    email: field("email", string, json),
    id: field("id", string, json),
    avatarUrl: option(field("avatarUrl", string), json),
    title: field("title", string, json),
  }
}
