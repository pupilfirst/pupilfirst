type t = {
  id: string,
  title: string,
  createdAt: Js.Date.t,
  repliesCount: int,
}

let id = t => t.id
let title = t => t.title
let createdAt = t => t.createdAt
let repliesCount = t => t.repliesCount

let makeFromJs = jsObject => {
  id: jsObject["id"],
  title: jsObject["title"],
  createdAt: jsObject["createdAt"] |> DateFns.decodeISO,
  repliesCount: jsObject["liveRepliesCount"],
}
