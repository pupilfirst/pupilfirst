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
  links: list(Link.t),
  files: list(File.t),
  image: option(string),
  latestFeedback: option(string),
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

let statusStringWithGrade = status =>
  switch (status) {
  | Reviewed(reviewedStatus) =>
    switch (reviewedStatus) {
    | Verified(grade) =>
      "Verified"
      ++ " (Grade: "
      ++ (grade |> gradeString |> String.capitalize)
      ++ ")"
    | NeedsImprovement
    | NotAccepted => statusString(status)
    }
  | NotReviewed => statusString(status)
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
    links: json |> field("links", list(Link.decode)),
    files: json |> field("files", list(File.decode)),
    image: json |> field("image",nullable(string)) |> Js.Null.toOption,
    latestFeedback:
      json |> field("latestFeedback", nullable(string)) |> Js.Null.toOption,
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

let links = t => t.links;

let files = t => t.files;

let image = t => t.image;

let status = t => t.status;

let latestFeedback = t => t.latestFeedback;

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

let updateFeedback = (latestFeedback, t) => {
  ...t,
  latestFeedback: Some(latestFeedback),
};