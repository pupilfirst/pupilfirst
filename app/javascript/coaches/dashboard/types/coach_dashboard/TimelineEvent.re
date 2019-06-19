type t = {
  id: int,
  title: string,
  description: string,
  createdAt: DateTime.t,
  founderIds: list(int),
  links: list(string),
  files: list(File.t),
  latestFeedback: option(string),
  evaluation: list(Grading.t),
  rubric: option(string),
  evaluator: option(string),
};

type reviewResult =
  | Passed
  | Failed;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    title: json |> field("title", string),
    description: json |> field("description", string),
    createdAt: json |> field("createdAt", string) |> DateTime.parse,
    founderIds: json |> field("founderIds", list(int)),
    links: json |> field("links", list(string)),
    files: json |> field("files", list(File.decode)),
    latestFeedback:
      json |> field("latestFeedback", nullable(string)) |> Js.Null.toOption,
    evaluation: json |> field("evaluation", list(Grading.decode)),
    rubric: json |> field("rubric", nullable(string)) |> Js.Null.toOption,
    evaluator:
      json |> field("evaluator", nullable(string)) |> Js.Null.toOption,
  };

let forFounder = (founder, tes) =>
  tes |> List.filter(te => List.mem(founder |> Founder.id, te.founderIds));

let id = t => t.id;

let title = t => t.title;

let description = t => t.description;

let createdAt = t => t.createdAt;

let founderIds = t => t.founderIds;

let links = t => t.links;

let files = t => t.files;

let latestFeedback = t => t.latestFeedback;

let updateEvaluation = (evaluation, t) => {...t, evaluation};

let updateFeedback = (latestFeedback, t) => {
  ...t,
  latestFeedback: Some(latestFeedback),
};

let updateEvaluator = (evaluator, t) => {...t, evaluator: Some(evaluator)};

let reviewPending = tes =>
  tes |> List.filter(te => te.evaluation |> Grading.pending);

let reviewComplete = tes =>
  tes |> List.filter(te => !(te.evaluation |> Grading.pending));

let getReviewResult = (passGrade, t) =>
  t.evaluation |> Grading.anyFail(passGrade) ? Failed : Passed;

let resultAsString = reviewResult =>
  switch (reviewResult) {
  | Passed => "Passed"
  | Failed => "Failed"
  };

let evaluation = t => t.evaluation;

let rubric = t => t.rubric;

let evaluator = t => t.evaluator;
