type rec t = {
  id: id,
  title: string,
  topicCategoryId: option<string>,
  lockedAt: option<Js.Date.t>,
  lockedById: option<string>,
}
and id = string

let title = t => t.title

let lockedAt = t => t.lockedAt

let lockedById = t => t.lockedById

let id = t => t.id

let topicCategoryId = t => t.topicCategoryId

let updateTitle = (title, t) => {
  ...t,
  title: title,
}

let lock = (lockedById, t) => {
  ...t,
  lockedAt: Some(Js.Date.make()),
  lockedById: Some(lockedById),
}

let unlock = t => {
  ...t,
  lockedAt: None,
  lockedById: None,
}

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    title: json |> field("title", string),
    topicCategoryId: json |> optional(field("topicCategoryId", string)),
    lockedAt: json |> optional(field("lockedAt", DateFns.decodeISO)),
    lockedById: json |> optional(field("lockedById", string)),
  }
}
