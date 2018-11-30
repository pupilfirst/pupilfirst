type t = {
  id: int,
  value: string,
  hint: string,
  correctAnswer: bool,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    value: json |> field("value", string),
    hint: json |> field("hint", string),
    correctAnswer: json |> field("correctAnswer", bool),
  };

let id = t => t.id;

let value = t => t.value;

let hint = t => t.hint;

let correctAnswer = t => t.correctAnswer;