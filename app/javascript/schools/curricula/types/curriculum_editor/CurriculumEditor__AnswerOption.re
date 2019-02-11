type t = {
  id: int,
  answer: string,
  description: option(string),
  correctAnswer: bool,
};

let id = t => t.id;

let answer = t => t.answer;

let description = t => t.description;

let correctAnswer = t => t.correctAnswer;

let empty = id => {id, answer: "", description: None, correctAnswer: false};

let updateAnswer = (answer, t) => {...t, answer};

let updateDescription = (description, t) => {...t, description};

let markAsCorrect = t => {...t, correctAnswer: true};

let markAsIncorrect = t => {...t, correctAnswer: false};

let isValidAnswerOption = t =>
  t.answer |> Js.String.trim |> Js.String.length >= 1;