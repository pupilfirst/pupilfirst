type answerOption = {
  id: string,
  value: string,
  hint: string,
};

type t = {
  index: int,
  question: string,
  description: string,
  correctAnswerId: string,
  answerOptions: list(answerOption),
};

let decodeAnswerOption = json =>
  Json.Decode.{
    id: json |> field("id", string),
    value: json |> field("value", string),
    hint: json |> field("hint", string),
  };

let decode = json =>
  Json.Decode.{
    index: json |> field("index", int),
    question: json |> field("question", string),
    description: json |> field("description", string),
    correctAnswerId: json |> field("correctAnswerId", string),
    answerOptions: json |> field("answerOptions", list(decodeAnswerOption)),
  };