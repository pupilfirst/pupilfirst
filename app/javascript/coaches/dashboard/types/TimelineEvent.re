type status =
  | Verified
  | NotAccepted
  | Pending
  | NeedsImprovement;

type t = {
  id: int,
  title: string,
  description: string,
  status,
  eventOn: DateTime.t,
  startupId: int,
  startupName: string,
  founderId: int,
  founderName: string,
  submittedAt: DateTime.t,
};

module JsDecode = {
  [@bs.deriving abstract]
  type t = {
    id: int,
    title: string,
    description: string,
    status: string,
    eventOn: string,
    startupId: int,
    startupName: string,
    founderId: int,
    founderName: string,
    submittedAt: string,
  };
  let parseStatus = status =>
    switch (status) {
    | "Pending" => Pending
    | "Verified" => Verified
    | "Not Accepted" => NotAccepted
    | "Needs Improvement" => NeedsImprovement
    | _ => failwith("Invalid Status")
    };
};

let create = js_t => {
  id: js_t |> JsDecode.id,
  title: js_t |> JsDecode.title,
  description: js_t |> JsDecode.description,
  status: js_t |> JsDecode.status |> JsDecode.parseStatus,
  eventOn: js_t |> JsDecode.eventOn |> DateTime.parse,
  startupId: js_t |> JsDecode.startupId,
  startupName: js_t |> JsDecode.startupName,
  founderId: js_t |> JsDecode.founderId,
  founderName: js_t |> JsDecode.founderName,
  submittedAt: js_t |> JsDecode.submittedAt |> DateTime.parse,
};

let forStartupId = (startupId, tes) =>
  tes |> List.filter(te => te.startupId == startupId);

let verificationPending = tes =>
  tes |> List.filter(te => te.status == Pending);

let verificationComplete = tes =>
  tes |> List.filter(te => te.status != Pending);

let title = t => t.title;

let description = t => t.description;

let eventOn = t => t.eventOn;

let founderId = t => t.founderId;

let founderName = t => t.founderName;

let startupId = t => t.startupId;

let startupName = t => t.startupName;

let submittedAt = t => t.submittedAt;