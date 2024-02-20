%%raw(`import "./CoursesCurriculum__Quiz.css"`)

open CoursesCurriculum__Types

let str = React.string

let tr = I18n.t(~scope="components.CoursesCurriculum__Quiz")

module CreateQuizSubmissionQuery = %graphql(`
   mutation CreateQuizSubmissionMutation($targetId: ID!, $answerIds: [ID!]!) {
    createQuizSubmission(targetId: $targetId, answerIds: $answerIds){
      submission{
        id
        createdAt
        checklist
      }
     }
   }
 `)

let createQuizSubmission = (target, selectedAnswersIds, setSaving, addSubmissionCB) => {
  setSaving(_ => true)
  CreateQuizSubmissionQuery.make({targetId: target |> Target.id, answerIds: selectedAnswersIds})
  |> Js.Promise.then_(response => {
    switch response["createQuizSubmission"]["submission"] {
    | Some(submission) =>
      let checklist =
        submission["checklist"] |> Json.Decode.array(SubmissionChecklistItem.decode([]))

      addSubmissionCB(
        Submission.make(
          ~id=submission["id"],
          ~createdAt=DateFns.decodeISO(submission["createdAt"]),
          ~status=Submission.MarkedAsComplete,
          ~checklist,
          ~hiddenAt=None,
        ),
      )
    | None => setSaving(_ => false)
    }
    Js.Promise.resolve()
  })
  |> ignore
}
let answerOptionClasses = (answerOption, selectedAnswer) => {
  let defaultClasses = "quiz-root__answer bg-white flex items-center shadow border border-transparent rounded p-3 mt-3 cursor-pointer transition "
  switch selectedAnswer {
  | Some(answer) if answer == answerOption =>
    defaultClasses ++ "text-primary-500 shadow-md quiz-root__answer-selected "
  | Some(_otherAnswer) => defaultClasses
  | None => defaultClasses
  }
}

let iconClasses = (answerOption, selectedAnswer) => {
  let defaultClasses = "quiz-root__answer-option-icon mb-1 far fa-check-circle text-lg "
  switch selectedAnswer {
  | Some(answer) if answer == answerOption => defaultClasses ++ "text-primary-500"
  | Some(_otherAnswer) => defaultClasses ++ "text-gray-500"
  | None => defaultClasses ++ "text-gray-500"
  }
}

let handleSubmit = (answer, target, selectedAnswersIds, setSaving, addSubmissionCB, event) => {
  event |> ReactEvent.Mouse.preventDefault
  let answerIds = Js.Array.concat(selectedAnswersIds, [QuizQuestion.answerId(answer)])

  createQuizSubmission(target, answerIds, setSaving, addSubmissionCB)
}

@react.component
let make = (~target, ~targetDetails, ~addSubmissionCB, ~preview) => {
  let quizQuestions = targetDetails |> TargetDetails.quizQuestions
  let (saving, setSaving) = React.useState(() => false)
  let (selectedQuestion, setSelectedQuestion) = React.useState(() => quizQuestions[0])
  let (selectedAnswer, setSelectedAnswer) = React.useState(() => None)
  let (selectedAnswersIds, setSelectedAnswersIds) = React.useState(() => [])
  let currentQuestion = selectedQuestion
  <div className="bg-gray-50 rounded overflow-hidden relative mb-18 mt-4">
    <div className="p-2 md:p-5">
      <span className="font-semibold text-xs block uppercase text-gray-600">
        {tr("question") ++ " #" |> str}
        {string_of_int((currentQuestion |> QuizQuestion.index) + 1) |> str}
      </span>
      <MarkdownBlock
        markdown={currentQuestion |> QuizQuestion.question}
        className="text-lg md:text-xl"
        profile=Markdown.Permissive
      />
      <div className="pt-2 flex flex-col">
        {currentQuestion
        |> QuizQuestion.answerOptions
        |> Js.Array.map(answerOption =>
          <button
            className={answerOptionClasses(answerOption, selectedAnswer)}
            key={QuizQuestion.answerId(answerOption)}
            onClick={_ => setSelectedAnswer(_ => Some(answerOption))}>
            <FaIcon classes={iconClasses(answerOption, selectedAnswer)} />
            <MarkdownBlock
              markdown={QuizQuestion.answerValue(answerOption)}
              className="overflow-auto ms-2 w-full"
              profile=Markdown.Permissive
            />
          </button>
        )
        |> React.array}
      </div>
    </div>
    {switch selectedAnswer {
    | None => React.null
    | Some(answer) =>
      <div
        className="quiz-root__answer-submit-section flex justify-center rounded-b-lg text-center p-4 border-t border-gray-200 w-full">
        {currentQuestion |> QuizQuestion.isLastQuestion(quizQuestions)
          ? <button
              disabled={saving || preview}
              className="btn btn-primary"
              onClick={handleSubmit(
                answer,
                target,
                selectedAnswersIds,
                setSaving,
                addSubmissionCB,
              )}>
              {str(tr("submit_quiz"))}
            </button>
          : {
              let nextQuestion = currentQuestion |> QuizQuestion.nextQuestion(quizQuestions)
              <button
                className="btn btn-primary"
                onClick={_ => {
                  setSelectedQuestion(_ => nextQuestion)
                  setSelectedAnswersIds(_ =>
                    Js.Array.concat(selectedAnswersIds, [QuizQuestion.answerId(answer)])
                  )
                  setSelectedAnswer(_ => None)
                }}>
                {str(tr("next_question"))}
              </button>
            }}
      </div>
    }}
  </div>
}
