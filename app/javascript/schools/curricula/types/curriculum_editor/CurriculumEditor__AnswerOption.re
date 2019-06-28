type id = string;

type t = {
  id,
  answer: string,
  correctAnswer: bool,
};

let id = t => t.id;

let answer = t => t.answer;

let correctAnswer = t => t.correctAnswer;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    answer: json |> field("answer", string),
    correctAnswer: json |> field("correctAnswer", bool),
  };

let empty = (id, correctAnswer) => {id, answer: "", correctAnswer};

let updateAnswer = (answer, t) => {...t, answer};

let markAsCorrect = t => {...t, correctAnswer: true};

let markAsIncorrect = t => {...t, correctAnswer: false};

let isValidAnswerOption = t =>
  t.answer |> Js.String.trim |> Js.String.length >= 1;

let encoder = t =>
  Json.Encode.(
    object_([
      ("answer", t.answer |> string),
      ("correctAnswer", t.correctAnswer |> bool),
    ])
  );
