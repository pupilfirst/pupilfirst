let str = React.string;

open QuestionsShow__Types;

type state = {
  title: string,
  titleTimer: option(string),
  description: string,
  saving: bool,
};

let computeInitialState = question => {
  let (title, description) =
    switch (question) {
    | Some(question) => (
        question |> Question.title,
        question |> Question.description,
      )
    | None => ("", "")
    };

  {title, description, titleTimer: None, saving: false};
};

type action =
  | UpdateTitle(string)
  | UpdateDescription(string)
  | BeginSaving
  | FailSaving;

let reducer = (state, action) =>
  switch (action) {
  | UpdateTitle(title) => {...state, title}
  | UpdateDescription(description) => {...state, description}
  | BeginSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  };

module CreateQuestionQuery = [%graphql
  {|
  mutation CreateQuestionQuery($title: String!, $description: String!, $communityId: ID!, $targetId: ID) {
    createQuestion(description: $description, title: $title, communityId: $communityId, targetId: $targetId) @bsVariant {
      questionId
      errors
    }
  }
|}
];

module UpdateQuestionQuery = [%graphql
  {|
  mutation UpdateQuestionQuery($id: ID!, $title: String!, $description: String!) {
    updateQuestion(id: $id, title: $title, description: $description) @bsVariant {
      success
      errors
    }
  }
|}
];

module CreateQuestionError = {
  type t = [
    | `InvalidLengthTitle
    | `InvalidLengthDescription
    | `BlankCommunityID
  ];

  let notification = error =>
    switch (error) {
    | `InvalidLengthTitle => (
        "InvalidLengthTitle",
        "Supplied title must be between 1 and 250 characters in length",
      )
    | `InvalidLengthDescription => (
        "InvalidLengthDescription",
        "Supplied description must be greater than 1 characters in length",
      )
    | `BlankCommunityID => (
        "BlankCommunityID",
        "Community id is required for creating Answer",
      )
    };
};

module UpdateQuestionError = {
  type t = [ | `InvalidLengthTitle | `InvalidLengthDescription];

  let notification = error =>
    switch (error) {
    | `InvalidLengthTitle => (
        "InvalidLengthTitle",
        "Supplied title must be between 1 and 250 characters in length",
      )
    | `InvalidLengthDescription => (
        "InvalidLengthDescription",
        "Supplied description must be greater than 1 characters in length",
      )
    };
};

let handleResponseCB = (id, title) => {
  let window = Webapi.Dom.window;
  let parameterizedTitle =
    title
    |> Js.String.toLowerCase
    |> Js.String.replaceByRe([%re "/[^0-9a-zA-Z]+/gi"], "-");
  let redirectPath = "/questions/" ++ id ++ "/" ++ parameterizedTitle;
  redirectPath |> Webapi.Dom.Window.setLocation(window);
};

let handleBack = () =>
  Webapi.Dom.window |> Webapi.Dom.Window.history |> Webapi.Dom.History.back;

module CreateQuestionErrorHandler =
  GraphqlErrorHandler.Make(CreateQuestionError);

module UpdateQuestionErrorHandler =
  GraphqlErrorHandler.Make(UpdateQuestionError);

let isInvalidString = s => s |> String.trim == "";

let saveDisabled = state =>
  state.description |> isInvalidString || state.title |> isInvalidString;

let handleCreateOrUpdateQuestion =
    (state, send, communityId, target, question, updateQuestionCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  if (saveDisabled(state)) {
    send(BeginSaving);

    switch (question) {
    | Some(question) =>
      let id = question |> Question.id;
      UpdateQuestionQuery.make(
        ~id,
        ~title=state.title,
        ~description=state.description,
        (),
      )
      |> GraphqlQuery.sendQuery
      |> Js.Promise.then_(response =>
           switch (response##updateQuestion) {
           | `Success(updated) =>
             switch (updated, updateQuestionCB) {
             | (true, Some(questionCB)) =>
               questionCB(state.title, state.description);
               Notification.success("Done!", "Question Updated sucessfully");
             | (_, _) =>
               Notification.error(
                 "Something went wrong",
                 "Please refresh the page and try again",
               )
             };
             Js.Promise.resolve();
           | `Errors(errors) =>
             Js.Promise.reject(UpdateQuestionErrorHandler.Errors(errors))
           }
         )
      |> UpdateQuestionErrorHandler.catch(() => send(FailSaving))
      |> ignore;
    | None =>
      let targetId = target |> OptionUtils.map(QuestionsEditor__Target.id);

      CreateQuestionQuery.make(
        ~description=state.description,
        ~title=state.title,
        ~communityId,
        ~targetId?,
        (),
      )
      |> GraphqlQuery.sendQuery
      |> Js.Promise.then_(response =>
           switch (response##createQuestion) {
           | `QuestionId(questionId) =>
             handleResponseCB(questionId, state.title);
             Notification.success("Done!", "Question has been saved.");
             Js.Promise.resolve();
           | `Errors(errors) =>
             Js.Promise.reject(CreateQuestionErrorHandler.Errors(errors))
           }
         )
      |> CreateQuestionErrorHandler.catch(() => send(FailSaving))
      |> ignore;
    };
  } else {
    Notification.error(
      "Error!",
      "Question title and description must be present.",
    );
  };
};

[@react.component]
let make =
    (
      ~communityId,
      ~showBackButton=true,
      ~target,
      ~question=?,
      ~updateQuestionCB=?,
    ) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, question, computeInitialState);
  <DisablingCover disabled={state.saving}>
    <div className="bg-gray-100">
      <div className="flex-1 flex flex-col px-2">
        <div>
          {showBackButton
             ? <div className="max-w-3xl w-full mx-auto mt-5 pb-2">
                 <a className="btn btn-default" onClick={_ => handleBack()}>
                   <i className="fas fa-arrow-left" />
                   <span className="ml-2"> {"Back" |> str} </span>
                 </a>
               </div>
             : React.null}
        </div>
        {switch (target) {
         | Some(target) =>
           <div className="max-w-3xl w-full mt-5 mx-auto">
             <div
               className="flex py-4 px-4 md:px-5 w-full bg-white border border-primary-500  shadow-md rounded-lg justify-between items-center mb-2">
               <p className="w-3/5 md:w-4/5 text-sm">
                 <span className="font-semibold block text-xs">
                   {"Linked Target: " |> str}
                 </span>
                 <span>
                   {target |> QuestionsEditor__Target.title |> str}
                 </span>
               </p>
               <a href="./new_question" className="btn btn-default">
                 {"Clear" |> str}
               </a>
             </div>
           </div>
         | None => React.null
         }}
        <div
          className="mb-8 max-w-3xl w-full mx-auto relative shadow border bg-white rounded-lg">
          <div className="flex w-full flex-col py-4 px-4">
            <h5
              className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
              {(
                 switch (question) {
                 | Some(_) => "Edit Question"
                 | None => "Ask a new Question"
                 }
               )
               |> str}
            </h5>
            <label
              className="inline-block tracking-wide text-gray-900 text-xs font-semibold mb-2"
              htmlFor="title">
              {"Question" |> str}
            </label>
            <input
              id="title"
              value={state.title}
              className="appearance-none block w-full bg-white text-gray-900 font-semibold border border-gray-400 rounded py-3 px-4 mb-4 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
              onChange={event =>
                send(UpdateTitle(ReactEvent.Form.target(event)##value))
              }
              placeholder="Ask your question here briefly."
            />
            <label
              className="inline-block tracking-wide text-gray-900 text-xs font-semibold mb-2"
              htmlFor="description">
              {"Description" |> str}
            </label>
            <div className="w-full flex flex-col">
              <MarkdownEditor
                textareaId="description"
                onChange={markdown => send(UpdateDescription(markdown))}
                value={state.description}
                placeholder="Your description gives people the information they need to help you answer your question. You can use Markdown to format this text."
                profile=Markdown.QuestionAndAnswer
                maxLength=10000
              />
              <div className="flex justify-end pt-3 border-t">
                <button
                  disabled={saveDisabled(state)}
                  onClick={handleCreateOrUpdateQuestion(
                    state,
                    send,
                    communityId,
                    target,
                    question,
                    updateQuestionCB,
                  )}
                  className="btn btn-primary">
                  {(
                     switch (question) {
                     | Some(_) => "Update Question"
                     | None => "Post Your Question"
                     }
                   )
                   |> str}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </DisablingCover>;
};
