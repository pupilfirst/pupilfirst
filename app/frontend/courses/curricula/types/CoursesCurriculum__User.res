type t = {
  id: string,
  name: string,
  avatarUrl: option<string>,
  title: option<string>,
}

let id = t => t.id
let name = t => t.name
let avatarUrl = t => t.avatarUrl
let title = t => t.title

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    name: field("name", string, json),
    avatarUrl: option(field("avatarUrl", string), json),
    title: Js.Null.toOption(field("title", nullable(string), json)),
  }
}

let avatar = t =>
  avatarUrl(t)->Belt.Option.mapWithDefault(<Avatar className="w-full h-full" name=t.name />, src =>
    <img src />
  )
