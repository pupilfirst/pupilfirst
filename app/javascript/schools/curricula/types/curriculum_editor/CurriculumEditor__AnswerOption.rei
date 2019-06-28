type t;

type id = string;

let id: t => string;

let answer: t => string;

let correctAnswer: t => bool;

let decode: Js.Json.t => t;

let empty: (id, bool) => t;

let updateAnswer: (string, t) => t;

let markAsCorrect: t => t;

let markAsIncorrect: t => t;

let isValidAnswerOption: t => bool;

let encoder: t => Js.Json.t;
