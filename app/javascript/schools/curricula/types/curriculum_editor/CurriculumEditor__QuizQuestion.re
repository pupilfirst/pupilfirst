type t = {
  question: string,
  answerOptions: list(CurriculumEditor__AnswerOption.t),
};

let question = t => t.question;

let answerOptions = t => t.answerOptions;

let empty = () => {
  question: "",
  answerOptions: [CurriculumEditor__AnswerOption.empty()],
};

let updateQuestion = (t, question) => {...t, question};

let replace = (t, answerOptionA, answerOptionB) => {
  let oldAnswerOption =
    t.answerOptions |> List.filter(a => a != answerOptionA);
  {...t, answerOptions: [answerOptionB, ...oldAnswerOption]};
};