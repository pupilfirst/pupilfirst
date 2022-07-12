exception UnexpectedStatusValue(string)

type status =
  | MarkedAsComplete
  | Pending
  | Completed
  | Rejected

type t = {
  id: string,
  createdAt: Js.Date.t,
  status: status,
  checklist: array<SubmissionChecklistItem.t>,
}

let id = t => t.id
let createdAt = t => t.createdAt
let status = t => t.status
let checklist = t => t.checklist

let pending = t =>
  switch t.status {
  | Pending => true
  | MarkedAsComplete
  | Completed
  | Rejected => false
  }

let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy")

let sort = ts =>
  ts |> ArrayUtils.copyAndSort((t1, t2) => t2.createdAt->DateFns.differenceInSeconds(t1.createdAt))

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    createdAt: json |> field("createdAt", DateFns.decodeISO),
    status: switch json |> field("status", string) {
    | "marked_as_complete" => MarkedAsComplete
    | "pending" => Pending
    | "passed" => Completed
    | "failed" => Rejected
    | unknownValue => raise(UnexpectedStatusValue(unknownValue))
    },
    checklist: json |> field(
      "checklist",
      array(
        SubmissionChecklistItem.decode(
          json |> field("files", array(SubmissionChecklistItem.decodeFile)),
        ),
      ),
    ),
  }
}

let make = (~id, ~createdAt, ~status, ~checklist) => {
  id: id,
  createdAt: createdAt,
  status: status,
  checklist: checklist,
}
