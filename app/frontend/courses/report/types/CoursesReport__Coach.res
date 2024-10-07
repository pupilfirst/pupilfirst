type t = {
  name: string,
  title: string,
  avatarUrl: option<string>,
}

let name = t => t.name

let title = t => t.title

let avatarUrl = t => t.avatarUrl

let decode = json => {
  open Json.Decode
  {
    name: field("name", string, json),
    title: field("title", string, json),
    avatarUrl: field("avatarUrl", option(string), json),
  }
}
