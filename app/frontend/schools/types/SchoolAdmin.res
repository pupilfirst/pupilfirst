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

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    email: field("email", string, json),
    name: field("name", string, json),
    avatarUrl: option(field("avatarUrl", string), json),
  }
}

let create = (~id, ~name, ~email, ~avatarUrl) => {
  id,
  name,
  email,
  avatarUrl,
}

let update = (admin, admins) =>
  Array.append([admin], Js.Array.filter(a => a.id != admin.id, admins))

let sort = l => ArrayUtils.copyAndSort((x, y) => x.name < y.name ? -1 : 1, l)

let updateName = (name, t) => {...t, name}
