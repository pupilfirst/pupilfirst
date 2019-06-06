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

let index = t => t.index;

let question = t => t.question;

let description = t => t.description;

let answerOptions = t => t.answerOptions;

let id = answerOption => answerOption.id;

let value = answerOption => answerOption.value;

let hint = answerOption => answerOption.hint;

let correctAnswer = t =>
  t.answerOptions |> List.find(q => q |> id == t.correctAnswerId);

let lastQuestion = questions => {
  let maxIndex =
    questions
    |> List.sort((q1, q2) => q1.index - q2.index)
    |> List.rev
    |> List.hd
    |> index;
  questions |> List.find(q => q.index == maxIndex);
};

let nextQuestion = (questions, question) =>
  questions |> List.find(q => q.index == question.index + 1);

let isLastQuestion = (questions, question) =>
  questions |> lastQuestion == question;