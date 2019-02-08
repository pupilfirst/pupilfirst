open CurriculumEditor__Types;

let str = ReasonReact.string;

type state = {
  answerOption: AnswerOption.t,
  hasDescription: bool,
};

type action =
  | InvertHasDescription
  | UpdateAnswer(string);

let component =
  ReasonReact.reducerComponent("CurriculumEditor__TargetQuizAnswer");

let make = (~answerOption: AnswerOption.t, ~updateAnswerOptionCB, _children) => {
  ...component,
  initialState: () => {answerOption, hasDescription: false},
  reducer: (action, state) =>
    switch (action) {
    | UpdateAnswer(answer) =>
      ReasonReact.Update({
        ...state,
        answerOption: AnswerOption.create("shit", Some("deepShit"), true),
      })
    /* | UpdateDescription =>
       ReasonReact.Update({
         ...state,
         answerOption: answerOption |> AnswerOption.updateAnswer("deepShit"),
       }) */
    | InvertHasDescription =>
      ReasonReact.Update({...state, hasDescription: !state.hasDescription})
    },
  render: ({state, send}) =>
    <div>
      <div className="flex flex-col bg-white mb-2 border rounded">
        <div className="flex">
          <input
            className="appearance-none block w-full bg-white text-grey-darker text-sm rounded p-4 leading-tight focus:outline-none focus:bg-white focus:border-grey"
            id="answer option-1"
            type_="text"
            placeholder={answerOption |> AnswerOption.answer}
            onChange={
              event =>
                send(UpdateAnswer(ReactEvent.Form.target(event)##value))
                /* let answerOption =
                       state.answerOption
                       |> AnswerOption.updateAnswer(
                            ReactEvent.Form.target(event)##value,
                          );
                     updateAnswerOptionCB(state.answerOption, answerOption);
                   } */
            }
          />
          /* onClick={
               _event => {
                 ReactEvent.Mouse.preventDefault(_event);
                 addCorrectAnswerCB(state);
               }
             } */
          <button
            className="flex-no-shrink border border-l-1 border-r-0 border-t-0 border-b-0 text-grey hover:text-grey-darker text-xs py-1 px-3"
            type_="button">
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
          <button
            className="flex-no-shrink border border-l-1 border-r-0 border-t-0 border-b-0 text-grey hover:text-grey-darker text-xs py-1 px-3"
            type_="button">
            {"Add" |> str}
          </button>
        </div>
        {
          state.hasDescription ?
            <textarea
              className="appearance-none block w-full border-t border-t-1 border-grey-light bg-white text-grey-darker text-sm rounded rounded-t-none p-4 -mt-0 leading-tight focus:outline-none focus:bg-white focus:border-grey"
              id="title"
              placeholder="Type an answer explanation here."
              rows=3
            /> :
            ReasonReact.null
        }
      </div>
    </div>,
};