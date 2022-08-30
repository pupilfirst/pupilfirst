type answerOption = {
  id: string,
  value: string,
}

type t = {
  index: int,
  question: string,
  answerOptions: array<answerOption>,
}

let decodeAnswerOption = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    value: json |> field("value", string),
  }
}

let decode = json => {
  open Json.Decode
  {
    index: json |> field("index", int),
    question: json |> field("question", string),
    answerOptions: json |> field("answerOptions", array(decodeAnswerOption)),
  }
}

let index = t => t.index

let question = t => t.question

let answerOptions = t => t.answerOptions

let answerId = answerOption => answerOption.id

let answerValue = answerOption => answerOption.value

let lastQuestion = questions => {
  let maxIndex =
    ArrayUtils.copyAndSort((q1, q2) => q1.index - q2.index, questions)->ArrayUtils.last->index

  questions |> ArrayUtils.unsafeFind(
    q => q.index == maxIndex,
    "Could not find last question at index " ++ string_of_int(maxIndex),
  )
}

let nextQuestion = (questions, question) =>
  questions |> ArrayUtils.unsafeFind(
    q => q.index == question.index + 1,
    "Could not find a question at index " ++ string_of_int(question.index + 1),
  )

let isLastQuestion = (questions, question) => questions |> lastQuestion == question
