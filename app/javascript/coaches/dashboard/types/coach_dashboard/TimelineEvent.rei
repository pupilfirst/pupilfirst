type t;

let title: t => string;

let createdAt: t => DateTime.t;

let description: t => string;

let id: t => int;

let links: t => list(string);

let files: t => list(File.t);

let forFounder: (Founder.t, list(t)) => list(t);

let reviewPending: list(t) => list(t);

let reviewComplete: list(t) => list(t);

let decode: Js.Json.t => t;

let feedback: t => list(string);

let addFeedback: (string, t) => t;

let updateEvaluator: (string, t) => t;

let updateEvaluation: (list(Grading.t), t) => t;

let passed: (~passGrade: int, t) => bool;

let evaluation: t => list(Grading.t);

let founderIds: t => list(int);

let rubric: t => option(string);

let evaluator: t => option(string);
