type rec t = {
  id: id,
  name: string,
  title: string,
  affiliation: option<string>,
  avatarUrl: option<string>,
  about: option<string>,
  connectLink: option<string>,
  courseIds: array<string>,
}
and id = string

let id = t => t.id
let name = t => t.name
let title = t => t.title
let affiliation = t => t.affiliation
let avatarUrl = t => t.avatarUrl
let about = t => t.about
let connectLink = t => t.connectLink
let courseIds = t => t.courseIds

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    name: field("name", string, json),
    title: field("title", string, json),
    affiliation: optional(field("affiliation", string), json),
    avatarUrl: optional(field("avatarUrl", string), json),
    about: optional(field("about", string), json),
    connectLink: optional(field("connectLink", string), json),
    courseIds: field("courseIds", array(string), json),
  }
}

let fullTitle = t =>
  switch t.affiliation {
  | Some(affiliation) => t.title ++ (", " ++ affiliation)
  | None => t.title
  }
