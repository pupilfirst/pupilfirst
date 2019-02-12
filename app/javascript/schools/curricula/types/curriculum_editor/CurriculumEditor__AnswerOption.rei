type t;

let id: t => int;

let answer: t => string;

let description: t => option(string);

let correctAnswer: t => bool;

let empty: (int, bool) => t;

let updateAnswer: (string, t) => t;

let updateDescription: (option(string), t) => t;

let markAsCorrect: t => t;

let markAsIncorrect: t => t;

let isValidAnswerOption: t => bool;