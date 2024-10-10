let str = React.string

let t = I18n.t(~scope="components.CurriculumEditor__TargetQuizQuestion", ...)
let ts = I18n.t(~scope="shared", ...)

@react.component
let make = (
  ~questionNumber,
  ~quizQuestion,
  ~updateQuizQuestionCB,
  ~removeQuizQuestionCB,
  ~questionCanBeRemoved,
) => {
  let answerOptionId = (questionId, index) =>
    questionId ++ ("-answer-option-" ++ string_of_int(index + 1))

  let updateQuestion = question =>
    updateQuizQuestionCB(
      CurriculumEditor__QuizQuestion.id(quizQuestion),
      CurriculumEditor__QuizQuestion.updateQuestion(question, quizQuestion),
    )

  let updateAnswerOptionCB = (id, answer) =>
    updateQuizQuestionCB(
      CurriculumEditor__QuizQuestion.id(quizQuestion),
      CurriculumEditor__QuizQuestion.replace(id, answer, quizQuestion),
    )
  let removeAnswerOptionCB = id =>
    updateQuizQuestionCB(
      CurriculumEditor__QuizQuestion.id(quizQuestion),
      CurriculumEditor__QuizQuestion.removeAnswerOption(id, quizQuestion),
    )
  let markAsCorrectCB = id =>
    updateQuizQuestionCB(
      CurriculumEditor__QuizQuestion.id(quizQuestion),
      CurriculumEditor__QuizQuestion.markAsCorrect(id, quizQuestion),
    )

  let addAnswerOption = () =>
    updateQuizQuestionCB(
      CurriculumEditor__QuizQuestion.id(quizQuestion),
      CurriculumEditor__QuizQuestion.newAnswerOption(
        Js.Float.toString(Js.Date.now()),
        quizQuestion,
      ),
    )
  let canBeDeleted = Array.length(CurriculumEditor__QuizQuestion.answerOptions(quizQuestion)) > 2
  let questionId = "quiz-question-" ++ questionNumber

  <div className="quiz-maker__question-container p-4 bg-gray-50 rounded-lg border mt-4">
    <div className="flex items-center justify-between">
      <label
        className="block tracking-wide uppercase text-gray-800 text-sm font-bold"
        htmlFor=questionId>
        {str(t("question") ++ " " ++ questionNumber)}
      </label>
      <div className="quiz-maker__question-remove-button invisible">
        {questionCanBeRemoved
          ? <button
              className="flex items-center shrink-0 bg-white p-2 rounded-lg text-gray-600 hover:text-gray-600 text-xs"
              type_="button"
              title={t("remove_question")}
              onClick={event => {
                ReactEvent.Mouse.preventDefault(event)
                removeQuizQuestionCB(CurriculumEditor__QuizQuestion.id(quizQuestion))
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
        value={CurriculumEditor__QuizQuestion.question(quizQuestion)}
        onChange=updateQuestion
        profile=Markdown.Permissive
      />
    </div>
    <div className="quiz-maker__answers-container relative">
      {React.array(
        Array.mapi(
          (index, answerOption) =>
            <CurriculumEditor__TargetQuizAnswer
              key={CurriculumEditor__AnswerOption.id(answerOption)}
              answerOption
              updateAnswerOptionCB
              removeAnswerOptionCB
              canBeDeleted
              markAsCorrectCB
              answerOptionId={answerOptionId(questionId, index)}
            />,
          CurriculumEditor__QuizQuestion.answerOptions(quizQuestion),
        ),
      )}
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
          {str(t("add_another_answer"))}
        </p>
      </button>
    </div>
  </div>
}
