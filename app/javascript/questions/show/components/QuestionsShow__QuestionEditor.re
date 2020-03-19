let str = React.string;

open QuestionsShow__Types;

type state = {
  title: string,
  titleTimeoutId: option(Js.Global.timeoutId),
  suggestions: array(QuestionSuggestion.t),
  searching: bool,
  showSuggestions: bool,
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

  {
    title,
    description,
    titleTimeoutId: None,
    suggestions: [||],
    searching: false,
    showSuggestions: false,
    saving: false,
  };
};

type action =
  | UpdateTitle(string, option(Js.Global.timeoutId))
  | UpdateDescription(string)
  | BeginSaving
  | FailSaving
  | BeginSearching
  | FinishSearching(array(QuestionSuggestion.t))
  | FailSearching
  | ShowSuggestions;

let reducer = (state, action) =>
  switch (action) {
  | UpdateTitle(title, titleTimeoutId) =>
    let (suggestions, showSuggestions) =
      switch (titleTimeoutId) {
      | Some(_) => (state.suggestions, state.showSuggestions)
      | None => ([||], false)
      };

    {...state, title, titleTimeoutId, suggestions, showSuggestions};
  | UpdateDescription(description) => {...state, description}
  | BeginSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | BeginSearching => {...state, searching: true}
  | FinishSearching(suggestions) =>
    let showSuggestions =
      suggestions |> ArrayUtils.isEmpty ? false : state.showSuggestions;

    {...state, searching: false, suggestions, showSuggestions};
  | FailSearching => {...state, searching: false}
  | ShowSuggestions => {...state, showSuggestions: true}
  };

module SimilarQuestionsQuery = [%graphql
  {|
    query SimilarQuestionsQuery($communityId: ID!, $title: String!) {
      similarQuestions(communityId: $communityId, title: $title) {
        id
        title
        createdAt
        answersCount
      }
    }
  |}
];

let searchForSimilarQuestions = (send, title, communityId, ()) => {
  send(BeginSearching);

  let trimmedTitle = title |> String.trim;

  SimilarQuestionsQuery.make(~communityId, ~title=trimmedTitle, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(result => {
       let suggestions =
         result##similarQuestions |> Array.map(QuestionSuggestion.makeFromJs);
       send(FinishSearching(suggestions));
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(e => {
       Js.log(e);
       Notification.warn(
         "Oops!",
         "We failed to fetch similar questions from the server! Our team has been notified about this error.",
       );
       send(FailSaving);
       Js.Promise.resolve();
     })
  |> ignore;
};

let isInvalidString = s => s |> String.trim == "";

let updateTitle = (state, send, communityId, title) => {
  state.titleTimeoutId->Belt.Option.forEach(Js.Global.clearTimeout);

  let timeoutId =
    if (title |> isInvalidString) {
      None;
    } else {
      let timeoutId =
        Js.Global.setTimeout(
          searchForSimilarQuestions(send, state.title, communityId),
          1500,
        );
      Some(timeoutId);
    };

  send(UpdateTitle(title, timeoutId));
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
      let targetId = target |> OptionUtils.map(LinkedTarget.id);

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

let suggestions = state =>
  state.suggestions |> ArrayUtils.isNotEmpty && state.showSuggestions
    ? <div className="mt-3">
        <span className="tracking-wide text-gray-900 text-xs font-semibold">
          {"Similar Questions" |> str}
        </span>
        {state.suggestions
         |> Array.map(suggestion => {
              let askedOn =
                suggestion
                |> QuestionSuggestion.createdAt
                |> DateTime.format(DateTime.OnlyDate);
              let answers = suggestion |> QuestionSuggestion.answersCount;
              let answersCountPrefix = answers == 1 ? " answer" : " answers";

              <div
                key={suggestion |> QuestionSuggestion.id}
                className="mt-2 p-2 bg-gray-100 hover:bg-gray-200 rounded-lg cursor-pointer">
                <div className="font-semibold">
                  {suggestion |> QuestionSuggestion.title |> str}
                </div>
                <div className="flex mt-1 items-center">
                  <div className="text-xs">
                    {"Asked on " ++ askedOn |> str}
                  </div>
                  <div
                    className="text-xs px-1 py-px border border-transparent rounded bg-green-200 font-semibold ml-2">
                    {(answers |> string_of_int) ++ answersCountPrefix |> str}
                  </div>
                </div>
              </div>;
            })
         |> React.array}
      </div>
    : React.null;

let suggestionsButton = (state, send) => {
  let suggestionsCount = state.suggestions |> Array.length;

  if (state.searching) {
    <div className="mr-2"> <FaIcon classes="fas fa-spinner fa-pulse" /> </div>;
  } else if (suggestionsCount > 0 && !state.showSuggestions) {
    let questionsPrefix = suggestionsCount > 1 ? "questions" : "question";
    <button
      className="mr-2 btn btn-primary-ghost"
      onClick={_ => send(ShowSuggestions)}>
      {"Show "
       ++ (suggestionsCount |> string_of_int)
       ++ " similar "
       ++ questionsPrefix
       |> str}
    </button>;
  } else {
    React.null;
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
                 <span> {target |> LinkedTarget.title |> str} </span>
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
                ReactEvent.Form.target(event)##value
                |> updateTitle(state, send, communityId)
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
              <div className="border-t">
                {suggestions(state)}
                <div className="flex justify-end mt-3 items-center">
                  {suggestionsButton(state, send)}
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
                    className="btn btn-primary border border-transparent">
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
    </div>
  </DisablingCover>;
};
