type t;

let decode: Js.Json.t => t;

let index: t => int;

let question: t => string;

let description: t => option(string);

let correctAnswer: t => Quiz__Answer.t;

let answerOptions: t => list(Quiz__Answer.t);

let nextQuestion: (list(t), t) => t;

let isLastQuestion: (list(t), t) => bool;