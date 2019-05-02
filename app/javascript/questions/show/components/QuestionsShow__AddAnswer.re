[@bs.config {jsx: 3}];

open QuestionsShow__Types;

[@bs.val] external currentTime: unit => string = "Date.now";

module CreateAnswerQuery = [%graphql
  {|
  mutation($description: String!, $questionId: ID!) {
    createAnswer(description: $description, questionId: $questionId) @bsVariant {
      answerId
      errors
    }
  }
|}
];

module CreateAnswerError = {
  type t = [ | `InvalidLengthAnswer | `BlankQuestionId];

  let notification = error =>
    switch (error) {
    | `InvalidLengthAnswer => (
        "InvalidLengthValue",
        "Supplied comment must be greater than 1 characters in length",
      )
    | `BlankQuestionId => (
        "BlankQuestionId",
        "Question id is required for creating Answer",
      )
    };
};

module CreateAnswerErrorHandler = GraphqlErrorHandler.Make(CreateAnswerError);

let str = React.string;

[@react.component]
let make = (~question, ~authenticityToken, ~currentUserId, ~addAnswerCB) => {
  let (description, setDescription) = React.useState(() => "");
  let (saving, setSaving) = React.useState(() => false);

  let dateTime =
    currentTime() |> DateTime.parse |> DateTime.format(DateTime.DateAndTime);

  let validAnswer = description |> Js.String.length > 1;

  let handleResponseCB = id => {
    let answer = Answer.create(id, description, currentUserId, dateTime);
    setDescription(_ => "");
    setSaving(_ => false);
    Js.log(saving);
    addAnswerCB(answer);
  };
  let handleCreateAnswer = event => {
    event |> ReactEvent.Mouse.preventDefault;

    if (validAnswer) {
      setSaving(_ => true);

      CreateAnswerQuery.make(
        ~description,
        ~questionId=question |> Question.id,
        (),
      )
      |> GraphqlQuery.sendQuery(authenticityToken)
      |> Js.Promise.then_(response =>
           switch (response##createAnswer) {
           | `AnswerId(answerId) =>
             handleResponseCB(answerId);
             Notification.success("Done!", "Answer has been saved.");
             Js.Promise.resolve();
           | `Errors(errors) =>
             Js.Promise.reject(CreateAnswerErrorHandler.Errors(errors))
           }
         )
      |> CreateAnswerErrorHandler.catch(() => setSaving(_ => false))
      |> ignore;
    } else {
      ();
    };
  };

  <div
    className="mt-4 max-w-md w-full flex mx-auto items-center justify-center relative shadow bg-white rounded-lg">
    <div className="flex w-full  py-4 px-4">
      <div className="w-full flex flex-col">
        <DisablingCover disabled=saving>
          <textarea
            maxLength=1000
            placeholder="Add your Answer"
            value=description
            onChange={
              event => setDescription(ReactEvent.Form.target(event)##value)
            }
            className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
          />
          <button
            onClick=handleCreateAnswer
            className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 shadow rounded focus:outline-none">
            {"Add Your Answer" |> str}
          </button>
        </DisablingCover>
      </div>
    </div>
  </div>;
};