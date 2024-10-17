type id = string

type t = {
  id: id,
  question: string,
  answerOptions: array<CurriculumEditor__AnswerOption.t>,
}

let id = t => t.id

let question = t => t.question

let answerOptions = t => t.answerOptions

let empty = id => {
  id,
  question: "",
  answerOptions: [
    CurriculumEditor__AnswerOption.empty("0", true),
    CurriculumEditor__AnswerOption.empty("1", false),
  ],
}

let updateQuestion = (question, t) => {...t, question}

let newAnswerOption = (id, t) => {
  let answerOption = CurriculumEditor__AnswerOption.empty(id, false)
  let newAnswerOptions = ArrayUtils.copyAndPush(answerOption, t.answerOptions)
  {...t, answerOptions: newAnswerOptions}
}

let removeAnswerOption = (id, t) => {
  let newAnswerOptions =
    t.answerOptions->Array.filter(a => CurriculumEditor__AnswerOption.id(a) !== id)
  {...t, answerOptions: newAnswerOptions}
}

let replace = (id, answerOptionB, t) => {
  let newAnswerOptions =
    t.answerOptions->Array.map(a => CurriculumEditor__AnswerOption.id(a) == id ? answerOptionB : a)
  {...t, answerOptions: newAnswerOptions}
}

let markAsCorrect = (id, t) => {
  let newAnswerOptions =
    t.answerOptions->Array.map(a =>
      CurriculumEditor__AnswerOption.id(a) == id
        ? CurriculumEditor__AnswerOption.markAsCorrect(a)
        : CurriculumEditor__AnswerOption.markAsIncorrect(a)
    )
  {...t, answerOptions: newAnswerOptions}
}

let isValidQuizQuestion = t => {
  let validQuestion = Js.String.length(String.trim(t.question)) >= 1
  let hasZeroInvalidAnswerOptions = ArrayUtils.isEmpty(
    t.answerOptions->Js.Array.filter(answerOption =>
      CurriculumEditor__AnswerOption.isValidAnswerOption(answerOption) != true
    ),
  )
  let hasOnlyOneCorrectAnswerOption =
    t.answerOptions
    ->Js.Array.filter(answerOption =>
      CurriculumEditor__AnswerOption.correctAnswer(answerOption) == true
    )
    ->Array.length == 1
  validQuestion && (hasZeroInvalidAnswerOptions && hasOnlyOneCorrectAnswerOption)
}

let makeFromJs = quizData => {
  id: quizData["id"],
  question: quizData["question"],
  answerOptions: quizData["answerOptions"]->Array.map(answerOption =>
    CurriculumEditor__AnswerOption.makeFromJs(answerOption)
  ),
}

let quizAsJsObject = quiz =>
  quiz->Array.map(quiz =>
    {
      "question": quiz.question,
      "answerOptions": CurriculumEditor__AnswerOption.quizAnswersAsJsObject(quiz.answerOptions),
    }
  )
