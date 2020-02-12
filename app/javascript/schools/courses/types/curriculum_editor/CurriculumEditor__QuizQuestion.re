type id = string;

type t = {
  id,
  question: string,
  answerOptions: list(CurriculumEditor__AnswerOption.t),
};

let id = t => t.id;

let question = t => t.question;

let answerOptions = t => t.answerOptions;

let empty = id => {
  id,
  question: "",
  answerOptions: [
    CurriculumEditor__AnswerOption.empty("0", true),
    CurriculumEditor__AnswerOption.empty("1", false),
  ],
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    question: json |> field("question", string),
    answerOptions:
      json
      |> field("answerOptions", list(CurriculumEditor__AnswerOption.decode)),
  };

let updateQuestion = (question, t) => {...t, question};

let newAnswerOption = (id, t) => {
  let answerOption = CurriculumEditor__AnswerOption.empty(id, false);
  let newAnswerOptions =
    t.answerOptions |> List.rev |> List.append([answerOption]) |> List.rev;
  {...t, answerOptions: newAnswerOptions};
};

let removeAnswerOption = (id, t) => {
  let newAnswerOptions =
    t.answerOptions
    |> List.filter(a => a |> CurriculumEditor__AnswerOption.id !== id);
  {...t, answerOptions: newAnswerOptions};
};

let replace = (id, answerOptionB, t) => {
  let newAnswerOptions =
    t.answerOptions
    |> List.map(a =>
         a |> CurriculumEditor__AnswerOption.id == id ? answerOptionB : a
       );
  {...t, answerOptions: newAnswerOptions};
};

let markAsCorrect = (id, t) => {
  let newAnswerOptions =
    t.answerOptions
    |> List.map(a =>
         a |> CurriculumEditor__AnswerOption.id == id
           ? CurriculumEditor__AnswerOption.markAsCorrect(a)
           : CurriculumEditor__AnswerOption.markAsIncorrect(a)
       );
  {...t, answerOptions: newAnswerOptions};
};

let isValidQuizQuestion = t => {
  let validQuestion = t.question |> Js.String.trim |> Js.String.length >= 1;
  let hasZeroInvalidAnswerOptions =
    t.answerOptions
    |> List.filter(answerOption =>
         answerOption
         |> CurriculumEditor__AnswerOption.isValidAnswerOption != true
       )
    |> List.length == 0;
  let hasOnlyOneCorrectAnswerOption =
    t.answerOptions
    |> List.filter(answerOption =>
         answerOption |> CurriculumEditor__AnswerOption.correctAnswer == true
       )
    |> List.length == 1;
  validQuestion && hasZeroInvalidAnswerOptions && hasOnlyOneCorrectAnswerOption;
};

let encoder = t =>
  Json.Encode.(
    object_([
      ("question", t.question |> string),
      (
        "answerOption",
        t.answerOptions |> list(CurriculumEditor__AnswerOption.encoder),
      ),
    ])
  );
