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
    id: json |> field("id", string),
    name: json |> field("name", string),
    avatarUrl: json |> optional(field("avatarUrl", string)),
    title: json |> field("title", nullable(string)) |> Js.Null.toOption,
  }
}

let avatar = t =>
  avatarUrl(t)->Belt.Option.mapWithDefault(<Avatar className="w-full h-full" name=t.name />, src =>
    <img src />
  )
