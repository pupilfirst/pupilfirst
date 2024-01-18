type id = string

type t = {
  id: id,
  userName: string,
  submissionId: string,
  comment: string,
  updatedAt: Js.Date.t,
}

let id = t => t.id
let userName = t => t.userName
let submissionId = t => t.submissionId
let comment = t => t.comment
let updatedAt = t => t.updatedAt

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    userName: json |> field("userName", string),
    submissionId: json |> field("submissionId", string),
    comment: json |> field("comment", string),
    updatedAt: json |> field("updatedAt", DateFns.decodeISO),
  }
}
