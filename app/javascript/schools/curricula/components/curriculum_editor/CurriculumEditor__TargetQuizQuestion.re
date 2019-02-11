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

    <div>
      <div
        className="flex bg-transparent items-center border-b border-b-1 border-grey-light py-2 mb-4 rounded">
        <input
          className="appearance-none bg-transparent text-lg border-none w-full text-grey-darker mr-3 py-1 px-2 pl-0 leading-tight focus:outline-none"
          type_="text"
          placeholder="Type the question here"
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
        className="flex items-center py-3 cursor-pointer">
        <svg className="svg-icon w-8 h-8" viewBox="0 0 20 20">
          <path
            fill="#A8B7C7"
            d="M13.388,9.624h-3.011v-3.01c0-0.208-0.168-0.377-0.376-0.377S9.624,6.405,9.624,6.613v3.01H6.613c-0.208,0-0.376,0.168-0.376,0.376s0.168,0.376,0.376,0.376h3.011v3.01c0,0.208,0.168,0.378,0.376,0.378s0.376-0.17,0.376-0.378v-3.01h3.011c0.207,0,0.377-0.168,0.377-0.376S13.595,9.624,13.388,9.624z M10,1.344c-4.781,0-8.656,3.875-8.656,8.656c0,4.781,3.875,8.656,8.656,8.656c4.781,0,8.656-3.875,8.656-8.656C18.656,5.219,14.781,1.344,10,1.344z M10,17.903c-4.365,0-7.904-3.538-7.904-7.903S5.635,2.096,10,2.096S17.903,5.635,17.903,10S14.365,17.903,10,17.903z"
          />
        </svg>
        <h5 className="font-semibold ml-2">
          {"Add another Answer Option" |> str}
        </h5>
      </div>
      {
        questionCanBeRemoved ?
          <button
            className="flex-no-shrink border border-l-1 border-r-0 border-t-0 border-b-0 text-grey hover:text-grey-darker text-xs py-1 px-3"
            type_="button"
            onClick={
              event => {
                ReactEvent.Mouse.preventDefault(event);
                removeQuizQuestionCB(quizQuestion |> QuizQuestion.id);
              }
            }>
            {"Remove Quiz Question" |> str}
          </button> :
          ReasonReact.null
      }
    </div>;
  },
};