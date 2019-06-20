type t;

type id = string;

let id: t => string;

let question: t => string;

let answerOptions: t => list(CurriculumEditor__AnswerOption.t);

let decode: Js.Json.t => t;

let empty: id => t;

let updateQuestion: (string, t) => t;

let newAnswerOption: (CurriculumEditor__AnswerOption.id, t) => t;

let removeAnswerOption: (CurriculumEditor__AnswerOption.id, t) => t;

let replace:
  (CurriculumEditor__AnswerOption.id, CurriculumEditor__AnswerOption.t, t) => t;

let markAsCorrect: (CurriculumEditor__AnswerOption.id, t) => t;

let isValidQuizQuestion: t => bool;

let encoder: t => Js.Json.t;
