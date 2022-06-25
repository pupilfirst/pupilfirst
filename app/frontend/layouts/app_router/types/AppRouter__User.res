type t = {
  id: string,
  name: string,
  title: string,
  isAdmin: bool,
  canEditProfile: bool,
  avatarUrl: option<string>,
  hasNotifications: bool,
  coachId: option<string>,
  isAuthor: bool,
}

let id = t => t.id
let name = t => t.name
let title = t => t.title
let isAdmin = t => t.isAdmin
let canEditProfile = t => t.canEditProfile
let avatarUrl = t => t.avatarUrl
let hasNotifications = t => t.hasNotifications
let coachId = t => t.coachId
let isAuthor = t => t.isAuthor

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    title: field("title", string, json),
    name: field("name", string, json),
    isAdmin: field("isAdmin", bool, json),
    canEditProfile: field("canEditProfile", bool, json),
    avatarUrl: optional(field("avatarUrl", string), json),
    hasNotifications: field("hasNotifications", bool, json),
    coachId: optional(field("coachId", string), json),
    isAuthor: field("isAuthor", bool, json),
  }
}

let empty = () => {
  id: "",
  name: "Unknown User",
  title: "Unknown",
  isAdmin: false,
  canEditProfile: false,
  avatarUrl: None,
  hasNotifications: false,
  coachId: None,
  isAuthor: false,
}

let defaultUser = currentUser => Belt.Option.getWithDefault(currentUser, empty())
