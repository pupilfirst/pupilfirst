type t;

let decode: Js.Json.t => t;

let grade: t => int;

let label: t => string;

let labelFor: (list(t), int) => string;

let maxGrade: list(t) => int;