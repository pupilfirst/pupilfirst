open CurriculumEditor__Types;

let str = ReasonReact.string;

type state = {hasDescription: bool};

type action =
  | InvertHasDescription;

let component =
  ReasonReact.reducerComponent("CurriculumEditor__TargetQuizAnswer");

let make =
    (
      ~answerOption: AnswerOption.t,
      ~updateAnswerOptionCB,
      ~removeAnswerOptionCB,
      ~canBeDeleted,
      ~markAsCorrectCB,
      _children,
    ) => {
  ...component,
  initialState: () => {hasDescription: false},
  reducer: (action, state) =>
    switch (action) {
    | InvertHasDescription =>
      ReasonReact.Update({hasDescription: !state.hasDescription})
    },
  render: ({state, send}) => {
    let description =
      switch (answerOption |> AnswerOption.description) {
      | Some(value) => value
      | None => ""
      };

    <div>
      <div className="flex flex-col bg-white mb-2 border rounded">
        <div className="flex">
          <input
            className="appearance-none block w-full bg-white text-grey-darker text-sm rounded p-4 leading-tight focus:outline-none focus:bg-white focus:border-grey"
            type_="text"
            placeholder="Answer option"
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
                "flex-no-shrink border border-l-1 border-r-0 border-t-0 border-b-0 text-green hover:text-grey-darker text-xs py-1 px-3" :
                "flex-no-shrink border border-l-1 border-r-0 border-t-0 border-b-0 text-grey hover:text-grey-darker text-xs py-1 px-3"
            }
            type_="button"
            onClick={
              _event => {
                ReactEvent.Mouse.preventDefault(_event);
                markAsCorrectCB(answerOption |> AnswerOption.id);
              }
            }>
            {"Mark as correct" |> str}
          </button>
          <button
            onClick={
              _event => {
                ReactEvent.Mouse.preventDefault(_event);
                send(InvertHasDescription);
              }
            }
            className="flex-no-shrink border border-l-1 border-r-0 border-t-0 border-b-0 text-grey hover:text-grey-darker text-xs py-1 px-3"
            type_="button">
            {"Explain" |> str}
          </button>
          {
            canBeDeleted ?
              <button
                className="flex-no-shrink border border-l-1 border-r-0 border-t-0 border-b-0 text-grey hover:text-grey-darker text-xs py-1 px-3"
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
          state.hasDescription ?
            <textarea
              className="appearance-none block w-full border-t border-t-1 border-grey-light bg-white text-grey-darker text-sm rounded rounded-t-none p-4 -mt-0 leading-tight focus:outline-none focus:bg-white focus:border-grey"
              id="title"
              placeholder="Type an answer explanation here."
              value=description
              rows=3
              onBlur={
                event => {
                  ReactEvent.Focus.preventDefault(event);
                  send(InvertHasDescription);
                }
              }
              onChange={
                event =>
                  updateAnswerOptionCB(
                    answerOption |> AnswerOption.id,
                    answerOption
                    |> AnswerOption.updateDescription(
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