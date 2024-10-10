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
  title,
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
    id: field("id", string, json),
    title: field("title", string, json),
    topicCategoryId: option(field("topicCategoryId", string), json),
    lockedAt: option(field("lockedAt", DateFns.decodeISO), json),
    lockedById: option(field("lockedById", string), json),
  }
}
