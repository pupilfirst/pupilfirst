[@bs.config {jsx: 3}];

let str = React.string;

module CreateQuestionQuery = [%graphql
  {|
  mutation($title: String!, $description: String!, $communityId: ID!) {
    createQuestion(description: $description, title: $title, communityId: $communityId) @bsVariant {
      questionId
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

let handleResponseCB = (id, title) => {
  let window = Webapi.Dom.window;
  let parameterizedTitle =
    title
    |> Js.String.toLowerCase
    |> Js.String.replaceByRe([%re "/[^0-9a-zA-Z]+/gi"], "-")
    |> Js.String.replaceByRe([%re "/\s/g"], "-");
  let redirectPath = "/questions/" ++ id ++ "/" ++ parameterizedTitle;
  redirectPath |> Webapi.Dom.Window.setLocation(window);
};

module CreateQuestionErrorHandler =
  GraphqlErrorHandler.Make(CreateQuestionError);

[@react.component]
let make = (~authenticityToken, ~communityId, ~communityPath) => {
  let (saving, setSaving) = React.useState(() => false);
  let (description, setDescription) = React.useState(() => "");
  let (title, setTitle) = React.useState(() => "");
  let updateDescriptionCB = description => setDescription(_ => description);
  let saveDisabled = description == "" || title == "";

  let handleCreateQuestion = event => {
    event |> ReactEvent.Mouse.preventDefault;
    if (description != "") {
      setSaving(_ => true);

      CreateQuestionQuery.make(~description, ~title, ~communityId, ())
      |> GraphqlQuery.sendQuery(authenticityToken)
      |> Js.Promise.then_(response =>
           switch (response##createQuestion) {
           | `QuestionId(questionId) =>
             handleResponseCB(questionId, title);
             Notification.success("Done!", "Question has been saved.");
             Js.Promise.resolve();
           | `Errors(errors) =>
             Js.Promise.reject(CreateQuestionErrorHandler.Errors(errors))
           }
         )
      |> CreateQuestionErrorHandler.catch(() => setSaving(_ => false))
      |> ignore;
    } else {
      Notification.error("Empty", "Answer cant be blank");
    };
  };

  <div className="flex flex-1 bg-grey-lightest">
    <div className="flex-1 flex flex-col">
      <div className="max-w-lg w-full mx-auto mt-5 pb-2">
        <a className="btn btn-default no-underline" href=communityPath>
          <i className="far fa-arrow-left" />
          <span className="ml-2"> {React.string("Back")} </span>
        </a>
      </div>
      <div
        className="mt-4 my-8 max-w-lg w-full flex mx-auto items-center justify-center relative shadow border bg-white rounded-lg">
        <div className="flex w-full flex-col py-4 px-4">
          <h5
            className="uppercase text-center border-b border-grey-light pb-2 mb-4">
            {"Ask a new Question" |> str}
          </h5>
          <label
            className="inline-block tracking-wide text-grey-darker text-xs font-semibold mb-2">
            {"Titile" |> str}
          </label>
          <input
            className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
            onChange={
              event => setTitle(ReactEvent.Form.target(event)##value)
            }
            placeholder="Add your title"
          />
          <div className="w-full flex flex-col">
            <DisablingCover disabled=saving>
              <MarkDownEditor
                placeholderText="Type your Answer"
                updateDescriptionCB
              />
            </DisablingCover>
            <div className="flex justify-start pt-3 border-t">
              <button
                disabled=saveDisabled
                onClick=handleCreateQuestion
                className="btn btn-primary btn-large">
                {"Post Your Answer" |> str}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>;
};