type answerOption = {
  id: string,
  value: string,
  hint: option(string),
};

type t = {
  index: int,
  question: string,
  description: option(string),
  correctAnswerId: string,
  answerOptions: list(answerOption),
};

let decodeAnswerOption = json =>
  Json.Decode.{
    id: json |> field("id", string),
    value: json |> field("value", string),
    hint: json |> field("hint", nullable(string)) |> Js.Null.toOption,
  };

let decode = json =>
  Json.Decode.{
    index: json |> field("index", int),
    question: json |> field("question", string),
    description:
      json |> field("description", nullable(string)) |> Js.Null.toOption,
    correctAnswerId: json |> field("correctAnswerId", string),
    answerOptions: json |> field("answerOptions", list(decodeAnswerOption)),
  };