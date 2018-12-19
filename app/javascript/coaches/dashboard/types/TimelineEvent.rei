type t;

type reviewResult =
  | Passed
  | Failed;

let title: t => string;

let eventOn: t => DateTime.t;

let description: t => string;

let startupName: t => string;

let id: t => int;

let links: t => list(Link.t);

let files: t => list(File.t);

let image: t => option(string);

let forStartupId: (int, list(t)) => list(t);

let reviewPending: list(t) => list(t);

let reviewComplete: list(t) => list(t);

let decode: Js.Json.t => t;

let latestFeedback: t => option(string);

let updateFeedback: (string, t) => t;

let updateEvaluation: (list(Grading.t), t) => t;

let getReviewResult: (int, t) => reviewResult;

let resultAsString: reviewResult => string;

let evaluation: t => list(Grading.t);

let founders: t => list(Founder.t);

let rubric: t => option(string);