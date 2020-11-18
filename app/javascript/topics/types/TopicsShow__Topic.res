type rec t = {
  id: id,
  title: string,
  topicCategoryId: option<string>,
}
and id = string

let title = t => t.title

let id = t => t.id

let topicCategoryId = t => t.topicCategoryId

let updateTitle = (title, t) => {
  ...t,
  title: title,
}

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    title: json |> field("title", string),
    topicCategoryId: json |> optional(field("topicCategoryId", string)),
  }
}
