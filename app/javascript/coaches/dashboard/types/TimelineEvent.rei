type t;

type reviewResult =
  | Passed
  | Failed;

let title: t => string;

let eventOn: t => DateTime.t;

let description: t => string;

let founderName: t => string;

let startupName: t => string;

let id: t => int;

let links: t => list(Link.t);

let files: t => list(File.t);

let image: t => option(string);

let forStartupId: (int, list(t)) => list(t);

let reviewPending: list(t) => list(t);

let graded: list(t) => list(t);

let decode: Js.Json.t => t;

let latestFeedback: t => option(string);

let updateFeedback: (string, t) => t;

let updateGrades: (list(Grade.t), t) => t;

let grades: t => list(Grade.t);

let evaluationCriteria: t => list(EvaluationCriterion.t);

let getReviewResult: (int, t) => reviewResult;

let resultAsString: reviewResult => string;