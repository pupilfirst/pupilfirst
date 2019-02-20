type t;

let id: t => int;

let question: t => string;

let answerOptions: t => list(CurriculumEditor__AnswerOption.t);

let decode: Js.Json.t => t;

let empty: int => t;

let updateQuestion: (string, t) => t;

let newAnswerOption: (int, t) => t;

let removeAnswerOption: (int, t) => t;

let replace: (int, CurriculumEditor__AnswerOption.t, t) => t;

let markAsCorrect: (int, t) => t;

let isValidQuizQuestion: t => bool;

let encoder: t => Js.Json.t;