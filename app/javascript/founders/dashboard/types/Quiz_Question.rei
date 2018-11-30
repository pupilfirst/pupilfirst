type t;

let decode: Js.Json.t => t;

let id: t => int;

let question: t => string;

let description: t => string;

let answer_options: t => list(Quiz_Answer.t);