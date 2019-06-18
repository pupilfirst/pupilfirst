type t;

let decode: Js.Json.t => t;

let grade: t => option(int);

let pending: list(t) => bool;

let isFail: (int, t) => bool;

let anyFail: (int, list(t)) => bool;

let clearedEvaluation: list(t) => list(t);

let criterionId: t => int;

let criterionName: t => string;

let updateGrade: (int, t) => t;

let gradingEncoder: t => Js.Json.t;

let make: (~criterionId: int, ~criterionName: string, ~grade: int) => t;
