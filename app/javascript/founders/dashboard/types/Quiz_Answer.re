type t = {
  value: string,
  hint: string,
  correctAnswer: bool,
};

let decode = json =>
  Json.Decode.{
    value: json |> field("value", string),
    hint: json |> field("hint", string),
    correctAnswer: json |> field("correctAnswer", bool),
  };

let value = t => t.value;

let hint = t => t.hint;

let correctAnswer = t => t.correctAnswer;