type t = {
  id: string,
  name: string,
  avatarUrl: option<string>,
  email: string,
}

let name = t => t.name
let avatarUrl = t => t.avatarUrl
let id = t => t.id
let email = t => t.email

module Decode = {
  open Json.Decode

  let author = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
    avatarUrl: field.optional("avatarUrl", option(string))->OptionUtils.flat,
    email: field.required("email", string),
  })
}

let create = (~id, ~name, ~email, ~avatarUrl) => {
  id,
  name,
  email,
  avatarUrl,
}

let sort = l => ArrayUtils.copyAndSort((x, y) => x.name < y.name ? -1 : 1, l)

let updateName = (name, t) => {...t, name}
