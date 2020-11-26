type t = {
  id: string,
  number: int,
  createdAt: Js.Date.t,
  updatedAt: Js.Date.t,
}

let id = t => t.id

let createdAt = t => t.createdAt

let updatedAt = t => t.updatedAt

let number = t => t.number

let make = (id, number, createdAt, updatedAt) => {
  id: id,
  number: number,
  createdAt: createdAt,
  updatedAt: updatedAt,
}

let makeArrayFromJs = js => {
  let length = js |> Array.length
  js
  |> ArrayUtils.copyAndSort((x, y) =>
    DateFns.differenceInSeconds(
      y["createdAt"]->DateFns.decodeISO,
      x["createdAt"]->DateFns.decodeISO,
    )
  )
  |> Array.mapi((number, c) =>
    make(
      c["id"],
      length - number,
      c["createdAt"]->DateFns.decodeISO,
      c["updatedAt"]->DateFns.decodeISO,
    )
  )
}

let versionAt = t => t.createdAt->DateFns.format("MMM d, yyyy HH:mm")

let isLatestTargetVersion = (versions, t) => {
  let length = versions |> Array.length
  t.number == length
}
