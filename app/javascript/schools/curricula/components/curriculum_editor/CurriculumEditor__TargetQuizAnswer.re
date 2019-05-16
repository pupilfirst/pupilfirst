open CurriculumEditor__Types;

let str = ReasonReact.string;

type state = {hasHint: bool};

type action =
  | InvertHasHint;

let component =
  ReasonReact.reducerComponent("CurriculumEditor__TargetQuizAnswer");

let make =
    (
      ~answerOption: AnswerOption.t,
      ~updateAnswerOptionCB,
      ~removeAnswerOptionCB,
      ~canBeDeleted,
      ~markAsCorrectCB,
      ~answerOptionId,
      _children,
    ) => {
  ...component,
  initialState: () => {hasHint: false},
  reducer: (action, state) =>
    switch (action) {
    | InvertHasHint => ReasonReact.Update({hasHint: !state.hasHint})
    },
  render: ({state, send}) => {
    let hint =
      switch (answerOption |> AnswerOption.hint) {
      | Some(value) => value
      | None => ""
      };

    <div className="relative">
      {
        answerOption |> AnswerOption.correctAnswer ?
        <div className="quiz-maker__answer-option-pointer flex justify-center items-center quiz-maker__answer-option-pointer--correct"
        >
          <Icon kind=Icon.Check size="2" />
        </div> :
        <div onClick={
              _event => {
                ReactEvent.Mouse.preventDefault(_event);
                markAsCorrectCB(answerOption |> AnswerOption.id);
              }}className="quiz-maker__answer-option-pointer cursor-pointer">
          ReasonReact.null
        </div>
      }
      <div
        id={answerOptionId ++ "_block"}
        className="flex flex-col bg-white mb-2 border rounded ml-12">
        <div className="flex">
          <input
            id=answerOptionId
            className="appearance-none block w-full bg-white text-gray-800 text-sm rounded px-4 py-3 leading-tight focus:outline-none focus:bg-white focus:border-gray"
            type_="text"
            placeholder="Answer option"
            value={answerOption |> AnswerOption.answer}
            onChange={
              event =>
                updateAnswerOptionCB(
                  answerOption |> AnswerOption.id,
                  answerOption
                  |> AnswerOption.updateAnswer(
                       ReactEvent.Form.target(event)##value,
                     ),
                )
            }
          />
          <button
            className={
              answerOption |> AnswerOption.correctAnswer ?
                "w-28 flex-no-shrink border border-l-1 border-r-0 border-t-0 border-b-0 text-green font-semibold cursor-default focus:outline-none text-xs py-1 px-2" :
                "w-28 flex-no-shrink border border-l-1 border-r-0 border-t-0 border-b-0 text-gray hover:text-gray-800 focus:outline-none text-xs py-1 px-2"
            }
            type_="button"
            onClick={
              _event => {
                ReactEvent.Mouse.preventDefault(_event);
                markAsCorrectCB(answerOption |> AnswerOption.id);
              }
            }>
            {
              answerOption |> AnswerOption.correctAnswer ?
                "Correct Answer" |> str :
                "Mark as correct" |> str
            }
          </button>
          <button
            onClick={
              _event => {
                ReactEvent.Mouse.preventDefault(_event);
                send(InvertHasHint);
              }
            }
            className="flex-no-shrink border border-l-1 border-r-0 border-t-0 border-b-0 text-gray hover:text-gray-800 focus:outline-none text-xs py-1 px-2"
            type_="button">
            {"Explain" |> str}
          </button>
          {
            canBeDeleted ?
              <button
                className="flex-no-shrink border border-l-1 border-r-0 border-t-0 border-b-0 text-gray hover:text-gray-800 focus:outline-none text-xs py-1 px-2"
                type_="button"
                onClick={
                  event => {
                    ReactEvent.Mouse.preventDefault(event);
                    removeAnswerOptionCB(answerOption |> AnswerOption.id);
                  }
                }>
                {"Remove" |> str}
              </button> :
              ReasonReact.null
          }
        </div>
        {
          state.hasHint ?
            <textarea
              className="appearance-none block w-full border-t border-t-1 border-gray-400 bg-white text-gray-800 text-sm rounded rounded-t-none p-4 leading-tight focus:outline-none focus:bg-white focus:border-gray"
              id={answerOptionId ++ "_hint"}
              placeholder="Type an answer explanation here."
              value=hint
              rows=3
              onChange={
                event =>
                  updateAnswerOptionCB(
                    answerOption |> AnswerOption.id,
                    answerOption
                    |> AnswerOption.updateHint(
                         Some(ReactEvent.Form.target(event)##value),
                       ),
                  )
              }
            /> :
            ReasonReact.null
        }
      </div>
    </div>;
  },
};