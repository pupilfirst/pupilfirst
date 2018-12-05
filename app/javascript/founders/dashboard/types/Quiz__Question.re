type t = {
  index: int,
  question: string,
  description: option(string),
  correctAnswer: Quiz__Answer.t,
  incorrectOptions: list(Quiz__Answer.t),
};

let decode = json =>
  Json.Decode.{
    index: json |> field("index", int),
    question: json |> field("question", string),
    description:
      json |> field("description", nullable(string)) |> Js.Null.toOption,
    correctAnswer: json |> field("correctAnswer", Quiz__Answer.decode),
    incorrectOptions:
      json |> field("incorrectOptions", list(Quiz__Answer.decode)),
  };

let index = t => t.index;

let question = t => t.question;

let description = t => t.description;

let correctAnswer = t => t.correctAnswer;

let answerOptions = t => [t.correctAnswer, ...t.incorrectOptions];

let lastQuestion = questions => {
  let maxIndex =
    questions
    |> List.sort((q1, q2) => q1.index - q2.index)
    |> List.rev
    |> List.hd
    |> index;
  questions |> List.find(q => q.index == maxIndex);
};

let nextQuestion = (question, questions) =>
  questions |> List.find(q => q.index == question.index + 1);