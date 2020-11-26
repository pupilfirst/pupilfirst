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
    name: json |> field("name", string),
    title: json |> field("title", string),
    avatarUrl: json |> field("avatarUrl", optional(string)),
  }
}
