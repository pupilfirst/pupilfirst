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
  links: list(Link.t),
};

let parseStatus = status =>
  switch (status) {
  | "Pending" => Pending
  | "Verified" => Verified
  | "Not Accepted" => NotAccepted
  | "Needs Improvement" => NeedsImprovement
  | _ => failwith("Invalid Status")
  };

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    title: json |> field("title", string),
    description: json |> field("description", string),
    status: json |> field("status", string) |> parseStatus,
    eventOn: json |> field("eventOn", string) |> DateTime.parse,
    startupId: json |> field("startupId", int),
    startupName: json |> field("startupName", string),
    founderId: json |> field("founderId", int),
    founderName: json |> field("founderName", string),
    submittedAt: json |> field("submittedAt", string) |> DateTime.parse,
    links: json |> field("links", list(Link.decode)),
  };

let forStartupId = (startupId, tes) =>
  tes |> List.filter(te => te.startupId == startupId);

let verificationPending = tes =>
  tes |> List.filter(te => te.status == Pending);

let verificationComplete = tes =>
  tes |> List.filter(te => te.status != Pending);

let id = t => t.id;

let title = t => t.title;

let description = t => t.description;

let eventOn = t => t.eventOn;

let founderId = t => t.founderId;

let founderName = t => t.founderName;

let startupId = t => t.startupId;

let startupName = t => t.startupName;

let submittedAt = t => t.submittedAt;

let links = t => t.links;