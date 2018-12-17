type t = {
  index: int,
  question: string,
  description: option(string),
  correctAnswerId: int,
  answerOptions: list(Quiz__Answer.t),
};

let decode = json =>
  Json.Decode.{
    index: json |> field("index", int),
    question: json |> field("question", string),
    description:
      json |> field("description", nullable(string)) |> Js.Null.toOption,
    correctAnswerId: json |> field("correctAnswerId", int),
    answerOptions: json |> field("answerOptions", list(Quiz__Answer.decode)),
  };

let index = t => t.index;

let question = t => t.question;

let description = t => t.description;

let answerOptions = t => t.answerOptions;

let correctAnswer = t =>
  t.answerOptions |> List.find(q => q |> Quiz__Answer.id == t.correctAnswerId);

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