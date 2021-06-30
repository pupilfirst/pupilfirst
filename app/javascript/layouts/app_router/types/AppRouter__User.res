type t = {
  name: string,
  title: string,
  isAdmin: bool,
  canEditProfile: bool,
  avatarUrl: option<string>,
}

let name = t => t.name
let title = t => t.title
let isAdmin = t => t.isAdmin
let canEditProfile = t => t.canEditProfile
let avatarUrl = t => t.avatarUrl

let decode = json => {
  open Json.Decode
  {
    title: field("title", string, json),
    name: field("name", string, json),
    isAdmin: field("isAdmin", bool, json),
    canEditProfile: field("canEditProfile", bool, json),
    avatarUrl: optional(field("avatarUrl", string), json),
  }
}
