type t;

let decode: Js.Json.t => t;

let index: t => int;

let question: t => string;

let description: t => option(string);

let correctAnswerId: t => int;

let answer_options: t => list(Quiz_Answer.t);