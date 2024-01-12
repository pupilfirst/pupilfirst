type id = string

type t = {
  id: id,
  userId: string,
  submissionId: string,
  reactionValue: string,
}

let id = t => t.id
let userId = t => t.userId
let submissionId = t => t.submissionId
let reactionValue = t => t.reactionValue

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    userId: json |> field("userId", string),
    submissionId: json |> field("submissionId", string),
    reactionValue: json |> field("reactionValue", string),
  }
}
