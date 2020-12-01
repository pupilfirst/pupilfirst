type t = {
  createdAt: Js.Date.t,
  value: string,
  coachName: option<string>,
  coachAvatarUrl: option<string>,
  coachTitle: string,
}
let value = t => t.value
let coachName = t =>
  switch t.coachName {
  | Some(name) => name
  | None => "Deleted Coach"
  }
let coachAvatarUrl = t => t.coachAvatarUrl
let coachTitle = t => t.coachTitle
let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy")

let make = (~coachName, ~coachAvatarUrl, ~coachTitle, ~createdAt, ~value) => {
  coachName: coachName,
  coachAvatarUrl: coachAvatarUrl,
  coachTitle: coachTitle,
  createdAt: createdAt,
  value: value,
}
