type t;

let id: t => int;

let answer: t => string;

let hint: t => option(string);

let correctAnswer: t => bool;

let decode: Js.Json.t => t;

let empty: (int, bool) => t;

let updateAnswer: (string, t) => t;

let updateHint: (option(string), t) => t;

let markAsCorrect: t => t;

let markAsIncorrect: t => t;

let isValidAnswerOption: t => bool;

let encoder: t => Js.Json.t;