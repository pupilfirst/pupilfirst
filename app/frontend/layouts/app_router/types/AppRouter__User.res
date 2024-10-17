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

module Decode = {
  open Json.Decode

  let user = object(field => {
    id: field.required("id", string),
    title: field.required("title", string),
    name: field.required("name", string),
    isAdmin: field.required("isAdmin", bool),
    canEditProfile: field.required("canEditProfile", bool),
    avatarUrl: field.optional("avatarUrl", option(string))->OptionUtils.flat,
    hasNotifications: field.required("hasNotifications", bool),
    coachId: field.optional("coachId", option(string))->OptionUtils.flat,
    isAuthor: field.required("isAuthor", bool),
  })
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
