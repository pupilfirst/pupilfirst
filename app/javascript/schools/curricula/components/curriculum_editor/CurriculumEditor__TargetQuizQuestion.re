open CurriculumEditor__Types;

let str = ReasonReact.string;

let component =
  ReasonReact.statelessComponent(
    "CurriculumEditor__TargetQuizQuestionCreator",
  );

let make =
    (
      ~quizQuestion,
      ~updateQuizQuestionCB,
      ~removeQuizQuestionCB,
      ~questionCanBeRemoved,
      _children,
    ) => {
  ...component,
  render: _self => {
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
        quizQuestion |> QuizQuestion.newAnswerOption(lastAnswerOptionID + 1),
      );
    };
    let canBeDeleted =
      quizQuestion |> QuizQuestion.answerOptions |> List.length > 2;

    <div className="quiz-maker__question-container relative my-4">
      <div className="flex items-end justify-between">
        <label
          className="block tracking-wide uppercase text-grey-darker text-xs font-semibold"
          htmlFor="Quiz question 1">
          {"Question 1" |> str}
        </label>
        <div className="quiz-maker__question-remove-button invisible">
          {
            questionCanBeRemoved ?
              <button
                className="flex items-center flex-no-shrink bg-white px-1 rounded-lg text-grey-dark hover:text-grey-darker text-xs"
                type_="button"
                title="Remove Quiz Question"
                onClick={
                  event => {
                    ReactEvent.Mouse.preventDefault(event);
                    removeQuizQuestionCB(quizQuestion |> QuizQuestion.id);
                  }
                }>
                <i className="material-icons">{"delete_outline" |> str}</i>
              </button> :
              ReasonReact.null
          }
        </div>
      </div>
      <div
        className="flex relative items-center my-2">
        <input
          className="w-full text-grey-darker border rounded-lg p-4 leading-tight focus:outline-none"
          type_="text"
          placeholder="Type the question here"
          value={quizQuestion |> QuizQuestion.question}
          onChange={
            event => updateQuestion(ReactEvent.Form.target(event)##value)
          }
        />
      </div>
      {
        quizQuestion
        |> QuizQuestion.answerOptions
        |> List.map(answerOption =>
             <CurriculumEditor__TargetQuizAnswer
               key={answerOption |> AnswerOption.id |> string_of_int}
               answerOption
               updateAnswerOptionCB
               removeAnswerOptionCB
               canBeDeleted
               markAsCorrectCB
             />
           )
        |> Array.of_list
        |> ReasonReact.array
      }
      <div
        onClick={
          _event => {
            ReactEvent.Mouse.preventDefault(_event);
            addAnswerOption();
          }
        }
        className="cursor-pointer relative">
        <div className="quiz-maker__answer-option-pointer">
        </div>
        <div className="flex items-center bg-white hover:bg-grey-lighter border rounded-lg ml-12 py-3 px-4">
          <i className="material-icons">{"add_circle_outline" |> str}</i>
          <h5 className="font-semibold ml-2 italic">
            {"Add another Answer Option" |> str}
          </h5>
        </div>
      </div>
    </div>;
  },
};