let str = React.string

let t = I18n.t(~scope="components.CurriculumEditor__TargetQuizQuestion")
let ts = I18n.t(~scope="shared")

@react.component
let make = (
  ~questionNumber,
  ~quizQuestion,
  ~updateQuizQuestionCB,
  ~removeQuizQuestionCB,
  ~questionCanBeRemoved,
) => {
  let answerOptionId = (questionId, index) =>
    questionId ++ ("-answer-option-" ++ (index + 1 |> string_of_int))

  let updateQuestion = question =>
    updateQuizQuestionCB(
      quizQuestion |> CurriculumEditor__QuizQuestion.id,
      quizQuestion |> CurriculumEditor__QuizQuestion.updateQuestion(question),
    )

  let updateAnswerOptionCB = (id, answer) =>
    updateQuizQuestionCB(
      quizQuestion |> CurriculumEditor__QuizQuestion.id,
      quizQuestion |> CurriculumEditor__QuizQuestion.replace(id, answer),
    )
  let removeAnswerOptionCB = id =>
    updateQuizQuestionCB(
      quizQuestion |> CurriculumEditor__QuizQuestion.id,
      quizQuestion |> CurriculumEditor__QuizQuestion.removeAnswerOption(id),
    )
  let markAsCorrectCB = id =>
    updateQuizQuestionCB(
      quizQuestion |> CurriculumEditor__QuizQuestion.id,
      quizQuestion |> CurriculumEditor__QuizQuestion.markAsCorrect(id),
    )

  let addAnswerOption = () =>
    updateQuizQuestionCB(
      quizQuestion |> CurriculumEditor__QuizQuestion.id,
      quizQuestion |> CurriculumEditor__QuizQuestion.newAnswerOption(
        Js.Date.now() |> Js.Float.toString,
      ),
    )
  let canBeDeleted =
    quizQuestion |> CurriculumEditor__QuizQuestion.answerOptions |> Array.length > 2
  let questionId = "quiz-question-" ++ questionNumber

  <div className="quiz-maker__question-container p-4 bg-gray-50 rounded-lg border mt-4">
    <div className="flex items-center justify-between">
      <label
        className="block tracking-wide uppercase text-gray-800 text-sm font-bold"
        htmlFor=questionId>
        {t("question") ++ " " ++ questionNumber |> str}
      </label>
      <div className="quiz-maker__question-remove-button invisible">
        {questionCanBeRemoved
          ? <button
              className="flex items-center shrink-0 bg-white p-2 rounded-lg text-gray-600 hover:text-gray-600 text-xs"
              type_="button"
              title={t("remove_question")}
              onClick={event => {
                ReactEvent.Mouse.preventDefault(event)
                removeQuizQuestionCB(quizQuestion |> CurriculumEditor__QuizQuestion.id)
              }}>
              <i className="fas fa-trash-alt text-lg" />
            </button>
          : React.null}
      </div>
    </div>
    <div className="my-2 bg-white">
      <MarkdownEditor
        textareaId=questionId
        placeholder={t("answer_placeholder")}
        value={quizQuestion |> CurriculumEditor__QuizQuestion.question}
        onChange=updateQuestion
        profile=Markdown.Permissive
      />
    </div>
    <div className="quiz-maker__answers-container relative">
      {quizQuestion
      |> CurriculumEditor__QuizQuestion.answerOptions
      |> Array.mapi((index, answerOption) =>
        <CurriculumEditor__TargetQuizAnswer
          key={answerOption |> CurriculumEditor__AnswerOption.id}
          answerOption
          updateAnswerOptionCB
          removeAnswerOptionCB
          canBeDeleted
          markAsCorrectCB
          answerOptionId={answerOptionId(questionId, index)}
        />
      )
      |> React.array}
      <button
        onClick={_event => {
          ReactEvent.Mouse.preventDefault(_event)
          addAnswerOption()
        }}
        className="quiz-maker__add-answer-option cursor-pointer relative flex w-full">
        <div
          className="flex items-center border border-dashed border-primary-500 justify-center text-gray-600 quiz-maker__add-answer-option-pointer quiz-maker__add-answer-option-pointer">
          <i className="fas fa-plus" />
        </div>
        <p
          className="quiz-maker__add-answer-option-button flex items-center flex-1 h-11 text-gray-900 bg-gray-50 border border-dashed border-primary-400 hover:bg-white hover:text-primary-500 hover:shadow-md rounded-lg ms-12 py-3 px-4 text-xs">
          {t("add_another_answer") |> str}
        </p>
      </button>
    </div>
  </div>
}
