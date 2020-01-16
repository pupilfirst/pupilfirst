type id = string;

type t = {
  id,
  question: string,
  answerOptions: array(TargetDetails__AnswerOption.t),
};

let id = t => t.id;

let question = t => t.question;

let answerOptions = t => t.answerOptions;

let empty = id => {
  id,
  question: "",
  answerOptions: [|
    TargetDetails__AnswerOption.empty("0", true),
    TargetDetails__AnswerOption.empty("1", false),
  |],
};

let updateQuestion = (question, t) => {...t, question};

let newAnswerOption = (id, t) => {
  let answerOption = TargetDetails__AnswerOption.empty(id, false);
  let newAnswerOptions =
    t.answerOptions
    |> Array.to_list
    |> List.rev
    |> List.append([answerOption])
    |> List.rev
    |> Array.of_list;
  {...t, answerOptions: newAnswerOptions};
};

let removeAnswerOption = (id, t) => {
  let newAnswerOptions =
    t.answerOptions
    |> Js.Array.filter(a => a |> TargetDetails__AnswerOption.id !== id);
  {...t, answerOptions: newAnswerOptions};
};

let replace = (id, answerOptionB, t) => {
  let newAnswerOptions =
    t.answerOptions
    |> Array.map(a =>
         a |> TargetDetails__AnswerOption.id == id ? answerOptionB : a
       );
  {...t, answerOptions: newAnswerOptions};
};

let markAsCorrect = (id, t) => {
  let newAnswerOptions =
    t.answerOptions
    |> Array.map(a =>
         a |> TargetDetails__AnswerOption.id == id
           ? TargetDetails__AnswerOption.markAsCorrect(a)
           : TargetDetails__AnswerOption.markAsIncorrect(a)
       );
  {...t, answerOptions: newAnswerOptions};
};

let isValidQuizQuestion = t => {
  let validQuestion = t.question |> Js.String.trim |> Js.String.length >= 1;
  let hasZeroInvalidAnswerOptions =
    t.answerOptions
    |> Js.Array.filter(answerOption =>
         answerOption
         |> TargetDetails__AnswerOption.isValidAnswerOption != true
       )
    |> ArrayUtils.isEmpty;
  let hasOnlyOneCorrectAnswerOption =
    t.answerOptions
    |> Js.Array.filter(answerOption =>
         answerOption |> TargetDetails__AnswerOption.correctAnswer == true
       )
    |> Array.length == 1;
  validQuestion && hasZeroInvalidAnswerOptions && hasOnlyOneCorrectAnswerOption;
};

let makeFromJs = quizData => {
  {
    id: quizData##id,
    question: quizData##question,
    answerOptions:
      quizData##answerOptions
      |> Array.map(answerOption =>
           answerOption |> TargetDetails__AnswerOption.makeFromJs
         ),
  };
};

let encoder = t =>
  Json.Encode.(
    object_([
      ("question", t.question |> string),
      (
        "answerOption",
        t.answerOptions |> array(TargetDetails__AnswerOption.encoder),
      ),
    ])
  );
