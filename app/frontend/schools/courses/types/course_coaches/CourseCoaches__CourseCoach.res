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

module Decode = {
  open Json.Decode

  let courseCoach = field => {
    name: field("name", string),
    email: field("email", string),
    id: field("id", string),
    avatarUrl: option(field("avatarUrl", option(string)))->OptionUtils.flat,
    title: field("title", string),
  }
}
