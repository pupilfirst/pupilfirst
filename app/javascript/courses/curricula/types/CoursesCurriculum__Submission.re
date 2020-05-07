exception UnexpectedStatusValue(string);

type status =
  | MarkedAsComplete
  | Pending
  | Passed
  | Failed;

type t = {
  id: string,
  createdAt: Js.Date.t,
  status,
  checklist: array(SubmissionChecklistItem.t),
};

let id = t => t.id;
let createdAt = t => t.createdAt;
let status = t => t.status;
let checklist = t => t.checklist;

let pending = t => {
  switch (t.status) {
  | Pending => true
  | MarkedAsComplete
  | Passed
  | Failed => false
  };
};

let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy");

let sort = ts =>
  ts->Belt.List.sort((t1, t2) => {
    t1.createdAt->DateFns.differenceInSeconds(t2.createdAt)
  });

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    createdAt: json |> field("createdAt", DateFns.decodeISO),
    status:
      switch (json |> field("status", string)) {
      | "marked_as_complete" => MarkedAsComplete
      | "pending" => Pending
      | "passed" => Passed
      | "failed" => Failed
      | unknownValue => raise(UnexpectedStatusValue(unknownValue))
      },
    checklist:
      json
      |> field(
           "checklist",
           array(
             SubmissionChecklistItem.decode(
               json
               |> field("files", array(SubmissionChecklistItem.decodeFile)),
             ),
           ),
         ),
  };

let make = (~id, ~createdAt, ~status, ~checklist) => {
  id,
  createdAt,
  status,
  checklist,
};
