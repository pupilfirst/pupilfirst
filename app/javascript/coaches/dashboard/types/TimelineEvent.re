type t = {
  id: int,
  title: string,
  description: string,
  eventOn: DateTime.t,
  startupId: int,
  startupName: string,
  founderId: int,
  founderName: string,
  links: list(Link.t),
  files: list(File.t),
  image: option(string),
  latestFeedback: option(string),
  grades: list(Grade.t),
  evaluationCriteria: list(EvaluationCriterion.t),
};

type reviewResult =
  | Passed
  | Failed;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    title: json |> field("title", string),
    description: json |> field("description", string),
    eventOn: json |> field("eventOn", string) |> DateTime.parse,
    startupId: json |> field("startupId", int),
    startupName: json |> field("startupName", string),
    founderId: json |> field("founderId", int),
    founderName: json |> field("founderName", string),
    links: json |> field("links", list(Link.decode)),
    files: json |> field("files", list(File.decode)),
    image: json |> field("image", nullable(string)) |> Js.Null.toOption,
    latestFeedback:
      json |> field("latestFeedback", nullable(string)) |> Js.Null.toOption,
    grades: json |> field("grades", list(Grade.decode)),
    evaluationCriteria:
      json |> field("evaluationCriteria", list(EvaluationCriterion.decode)),
  };

let forStartupId = (startupId, tes) =>
  tes |> List.filter(te => te.startupId == startupId);

let id = t => t.id;

let title = t => t.title;

let description = t => t.description;

let eventOn = t => t.eventOn;

let founderName = t => t.founderName;

let startupName = t => t.startupName;

let links = t => t.links;

let files = t => t.files;

let image = t => t.image;

let grades = t => t.grades;

let evaluationCriteria = t => t.evaluationCriteria;

let latestFeedback = t => t.latestFeedback;

let updateGrades = (grades, t) => {...t, grades};

let updateFeedback = (latestFeedback, t) => {
  ...t,
  latestFeedback: Some(latestFeedback),
};

let reviewPending = tes => tes |> List.filter(te => te.grades == []);

let graded = tes => tes |> List.filter(te => te.grades != []);

let getReviewResult = (passGrade, t) =>
  t.grades |> List.exists(grade => grade |> Grade.grade < passGrade) ?
    Failed : Passed;

let resultAsString = reviewResult =>
  switch (reviewResult) {
  | Passed => "Passed"
  | Failed => "Failed"
  };