type id = string

type t = {
  id: id,
  userId: string,
  userName: string,
  reactionableId: string,
  reactionableType: string,
  reactionValue: string,
  updatedAt: Js.Date.t,
}

let id = t => t.id
let userId = t => t.userId
let userName = t => t.userName
let reactionableId = t => t.reactionableId
let reactionableType = t => t.reactionableType
let reactionValue = t => t.reactionValue
let updatedAt = t => t.updatedAt

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    userId: json |> field("userId", string),
    userName: json |> field("userName", string),
    reactionableId: json |> field("reactionableId", string),
    reactionableType: json |> field("reactionableType", string),
    reactionValue: json |> field("reactionValue", string),
    updatedAt: json |> field("updatedAt", DateFns.decodeISO),
  }
}
