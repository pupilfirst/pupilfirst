type t = {
  answer: string,
  description: option(string),
  correctAnswer: bool,
};

let answer = t => t.answer;

let description = t => t.description;

let correctAnswer = t => t.correctAnswer;

let empty = () => {answer: "", description: None, correctAnswer: false};

let updateAnswer = (t, answer) => {...t, answer};

let create = (answer, description, correctAnswer) => {
  answer,
  description,
  correctAnswer,
};