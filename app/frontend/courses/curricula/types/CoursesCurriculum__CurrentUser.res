type t = {
  id: string,
  name: string,
  avatarUrl: option<string>,
  isAdmin: bool,
  isAuthor: bool,
  isCoach: bool,
  isStudent: bool,
}

let id = t => t.id
let name = t => t.name
let avatarUrl = t => t.avatarUrl
let isAdmin = t => t.isAdmin
let isAuthor = t => t.isAuthor
let isCoach = t => t.isCoach
let isStudent = t => t.isStudent

let isModerator = t => t.isAdmin || t.isCoach
let isParticipant = t => t.isAdmin || t.isAuthor || t.isCoach || t.isStudent

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    name: field("name", string, json),
    avatarUrl: option(field("avatarUrl", string), json),
    isAdmin: field("isAdmin", bool, json),
    isAuthor: field("isAuthor", bool, json),
    isCoach: field("isCoach", bool, json),
    isStudent: field("isStudent", bool, json),
  }
}

let avatar = t =>
  avatarUrl(t)->Belt.Option.mapWithDefault(<Avatar className="w-full h-full" name=t.name />, src =>
    <img src />
  )
