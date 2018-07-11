type grade =
  | Good
  | Great
  | Wow;

type reviewedStatus =
  | Verified(grade)
  | NotAccepted
  | NeedsImprovement;

type status =
  | Reviewed(reviewedStatus)
  | NotReviewed;

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
  files: list(File.t),
};

let parseStatus = (grade, status) =>
  switch (status) {
  | "Pending" => NotReviewed
  | "Verified" => Reviewed(Verified(grade |> Belt.Option.getExn))
  | "Not Accepted" => Reviewed(NotAccepted)
  | "Needs Improvement" => Reviewed(NeedsImprovement)
  | _ => failwith("Invalid Status " ++ status ++ " received!")
  };

let parseGrade = grade =>
  switch (grade) {
  | None => None
  | Some(grade) =>
    switch (grade) {
    | "good" => Some(Good)
    | "great" => Some(Great)
    | "wow" => Some(Wow)
    | _ => failwith("Invalid Grade " ++ grade ++ " received!")
    }
  };

let gradeString = grade =>
  switch (grade) {
  | Good => "good"
  | Great => "great"
  | Wow => "wow"
  };

let statusString = status =>
  switch (status) {
  | NotReviewed => "Pending"
  | Reviewed(reviewedStatus) =>
    switch (reviewedStatus) {
    | Verified(_grade) => "Verified"
    | NotAccepted => "Not Accepted"
    | NeedsImprovement => "Needs Improvement"
    }
  };

let decode = json => {
  let grade =
    json
    |> Json.Decode.(field("grade", nullable(string)))
    |> Js.Null.toOption
    |> parseGrade;
  Json.Decode.{
    id: json |> field("id", int),
    title: json |> field("title", string),
    description: json |> field("description", string),
    status: json |> field("status", string) |> parseStatus(grade),
    eventOn: json |> field("eventOn", string) |> DateTime.parse,
    startupId: json |> field("startupId", int),
    startupName: json |> field("startupName", string),
    founderId: json |> field("founderId", int),
    founderName: json |> field("founderName", string),
    submittedAt: json |> field("submittedAt", string) |> DateTime.parse,
    links: json |> field("links", list(Link.decode)),
    files: json |> field("files", list(File.decode)),
  };
};

let forStartupId = (startupId, tes) =>
  tes |> List.filter(te => te.startupId == startupId);

let verificationPending = tes =>
  tes |> List.filter(te => te.status == NotReviewed);

let verificationComplete = tes =>
  tes |> List.filter(te => te.status != NotReviewed);

let id = t => t.id;

let title = t => t.title;

let description = t => t.description;

let eventOn = t => t.eventOn;

let founderName = t => t.founderName;

let startupName = t => t.startupName;

let submittedAt = t => t.submittedAt;

let links = t => t.links;

let files = t => t.files;

let status = t => t.status;

let updateStatus = (status, t) => {...t, status};

let isVerified = t =>
  switch (t.status) {
  | NotReviewed => false
  | Reviewed(reviewedStatus) =>
    switch (reviewedStatus) {
    | Verified(_grade) => true
    | NotAccepted
    | NeedsImprovement => false
    }
  };