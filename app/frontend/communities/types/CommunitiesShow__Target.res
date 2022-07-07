type t = {
  id: string,
  title: string,
}

let id = t => t.id

let title = t => t.title

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    title: json |> field("title", string),
  }
}
