type id = string

type t = {
  id: id,
  userId: string,
  reportableId: string,
  reportableType: string,
  reason: string,
}

let id = t => t.id
let userId = t => t.userId
let reportableId = t => t.reportableId
let reportableType = t => t.reportableType
let reason = t => t.reason

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    userId: json |> field("userId", string),
    reportableId: json |> field("reportableId", string),
    reportableType: json |> field("reportableType", string),
    reason: json |> field("reason", string),
  }
}
