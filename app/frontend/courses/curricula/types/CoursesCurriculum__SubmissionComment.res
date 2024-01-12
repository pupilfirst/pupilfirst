type id = string

type t = {
  id: id,
  userId: string,
  submissionId: string,
  comment: string,
  updatedAt: Js.Date.t,
}

let id = t => t.id
let userId = t => t.userId
let submissionId = t => t.submissionId
let comment = t => t.comment
let updatedAt = t => t.updatedAt

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    userId: json |> field("userId", string),
    submissionId: json |> field("submissionId", string),
    comment: json |> field("comment", string),
    updatedAt: json |> field("updatedAt", DateFns.decodeISO),
  }
}
