[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

let str = React.string;

[@react.component]
let make =
    (
      ~questionNumber,
      ~quizQuestion,
      ~updateQuizQuestionCB,
      ~removeQuizQuestionCB,
      ~questionCanBeRemoved,
    ) => {
  let answerOptionId = (questionId, index) =>
    "quiz_question_"
    ++ questionId
    ++ "_answer_option_"
    ++ (index + 1 |> string_of_int);

  let updateQuestion = question =>
    updateQuizQuestionCB(
      quizQuestion |> QuizQuestion.id,
      quizQuestion |> QuizQuestion.updateQuestion(question),
    );

  let updateAnswerOptionCB = (id, answer) =>
    updateQuizQuestionCB(
      quizQuestion |> QuizQuestion.id,
      quizQuestion |> QuizQuestion.replace(id, answer),
    );
  let removeAnswerOptionCB = id =>
    updateQuizQuestionCB(
      quizQuestion |> QuizQuestion.id,
      quizQuestion |> QuizQuestion.removeAnswerOption(id),
    );
  let markAsCorrectCB = id =>
    updateQuizQuestionCB(
      quizQuestion |> QuizQuestion.id,
      quizQuestion |> QuizQuestion.markAsCorrect(id),
    );

  let addAnswerOption = () => {
    let lastAnswerOptionID =
      quizQuestion
      |> QuizQuestion.answerOptions
      |> List.rev
      |> List.hd
      |> AnswerOption.id;
    updateQuizQuestionCB(
      quizQuestion |> QuizQuestion.id,
      quizQuestion
      |> QuizQuestion.newAnswerOption(
           (lastAnswerOptionID |> int_of_string) + 1 |> string_of_int,
         ),
    );
  };
  let canBeDeleted =
    quizQuestion |> QuizQuestion.answerOptions |> List.length > 2;
  let questionId = questionNumber + 1 |> string_of_int;

  <div className="quiz-maker__question-container py-4">
    <div className="flex items-end justify-between">
      <label
        className="block tracking-wide uppercase text-gray-800 text-xs font-semibold"
        htmlFor={"quiz_question_" ++ questionId}>
        {"Question " ++ questionId |> str}
      </label>
      <div className="quiz-maker__question-remove-button invisible">
        {
          questionCanBeRemoved ?
            <button
              className="flex items-center flex-shrink-0 bg-white p-2 rounded-lg text-gray-600 hover:text-gray-700 text-xs"
              type_="button"
              title="Remove Quiz Question"
              onClick={
                event => {
                  ReactEvent.Mouse.preventDefault(event);
                  removeQuizQuestionCB(quizQuestion |> QuizQuestion.id);
                }
              }>
              <i className="fas fa-trash-alt text-lg" />
            </button> :
            ReasonReact.null
        }
      </div>
    </div>
    <div className="my-2">
      <MarkDownEditor
        textareaId={"quiz_question_" ++ questionId}
        placeholder="Type the question here (supports markdown)"
        value={quizQuestion |> QuizQuestion.question}
        updateDescriptionCB=updateQuestion
        profile=Markdown.Permissive
      />
    </div>
    <div className="quiz-maker__answers-container relative">
      {
        quizQuestion
        |> QuizQuestion.answerOptions
        |> List.mapi((index, answerOption) =>
             <CurriculumEditor__TargetQuizAnswer
               key={answerOption |> AnswerOption.id}
               answerOption
               updateAnswerOptionCB
               removeAnswerOptionCB
               canBeDeleted
               markAsCorrectCB
               answerOptionId={answerOptionId(questionId, index)}
             />
           )
        |> Array.of_list
        |> React.array
      }
      <div
        onClick={
          _event => {
            ReactEvent.Mouse.preventDefault(_event);
            addAnswerOption();
          }
        }
        className="quiz-maker__answer-option cursor-pointer relative">
        <div
          className="quiz-maker__answer-option-pointer quiz-maker__answer-option-pointer--add">
          <Icon kind=Icon.PlusCircle size="full" />
        </div>
        <a
          className="flex items-center h-11 bg-white hover:bg-gray-200 border rounded-lg ml-12 py-3 px-4">
          <p className="text-xs"> {"Add another Answer Option" |> str} </p>
        </a>
      </div>
    </div>
  </div>;
};
