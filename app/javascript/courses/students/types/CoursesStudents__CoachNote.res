type t = {
  id: string,
  author: option<User.t>,
  note: string,
  createdAt: Js.Date.t,
}

let make = (~id, ~note, ~createdAt, ~author) => {
  id: id,
  note: note,
  createdAt: createdAt,
  author: author,
}

let id = t => t.id

let note = t => t.note

let createdAt = t => t.createdAt

let author = t => t.author

let noteOn = t => t.createdAt->DateFns.format("MMMM d, yyyy")

let sort = notes =>
  notes |> ArrayUtils.copyAndSort((x, y) => DateFns.differenceInSeconds(y.createdAt, x.createdAt))

let makeFromJs = note =>
  make(
    ~id=note["id"],
    ~note=note["note"],
    ~createdAt=note["createdAt"]->DateFns.decodeISO,
    ~author=note["author"] |> OptionUtils.map(User.makeFromJs),
  )
