[@bs.config {jsx: 3}];

open QuestionsShow__Types;

let str = React.string;

module CreateCommentQuery = [%graphql
  {|
  mutation($value: String!, $commentableId: ID!, $commentableType: String!) {
    createComment(value: $value, commentableId: $commentableId, commentableType: $commentableType) @bsVariant {
      commentId
      errors
    }
  }
|}
];

module CreateCommentError = {
  type t = [
    | `InvalidCommentableType
    | `InvalidLengthValue
    | `BlankCommentableId
  ];

  let notification = error =>
    switch (error) {
    | `InvalidCommentableType => (
        "InvalidCommentableType",
        "Supplied type must be one of Question or Answer",
      )
    | `InvalidLengthValue => (
        "InvalidLengthValue",
        "Supplied comment must be greater than 1 characters in length",
      )
    | `BlankCommentableId => (
        "BlankCommentableId",
        "Commentable id is required for creating a Comment",
      )
    };
};

module CreateCommentErrorHandler =
  GraphqlErrorHandler.Make(CreateCommentError);

[@react.component]
let make =
    (
      ~authenticityToken,
      ~commentableType,
      ~commentableId,
      ~addCommentCB,
      ~currentUserId,
    ) => {
  let (value, setValue) = React.useState(() => "");
  let (saving, setSaving) = React.useState(() => false);
  let validComment = value |> Js.String.length > 1;

  let handleResponseCB = id => {
    let comment =
      Comment.create(
        id,
        value,
        currentUserId,
        commentableId,
        commentableType,
      );
    setValue(_ => "");
    setSaving(_ => false);
    addCommentCB(comment);
  };

  let handleCreateComment = event => {
    event |> ReactEvent.Mouse.preventDefault;

    if (validComment) {
      setSaving(_ => true);
      CreateCommentQuery.make(~value, ~commentableId, ~commentableType, ())
      |> GraphqlQuery.sendQuery(authenticityToken)
      |> Js.Promise.then_(response =>
           switch (response##createComment) {
           | `CommentId(commentId) =>
             handleResponseCB(commentId);
             Notification.success("Done!", "Comment has been saved.");
             Js.Promise.resolve();
           | `Errors(errors) =>
             Js.Promise.reject(CreateCommentErrorHandler.Errors(errors))
           }
         )
      |> CreateCommentErrorHandler.catch(() => setSaving(_ => false))
      |> ignore;
    } else {
      ();
    };
  };
  <div className="w-full flex flex-col mx-auto items-center justify-center">
    <div className="w-full">
      <DisablingCover disabled=saving containerClasses="flex flex-row">
        <input
          placeholder="Add your comment"
          value
          onChange={event => setValue(ReactEvent.Form.target(event)##value)}
          className="w-3/5 text-left border appearance-none block w-full leading-tight focus:outline-none focus:bg-white focus:border-grey"
        />
        {
          validComment ?
            <button
              onClick=handleCreateComment
              className="w-2/5 border-2 border-primary-lighter py-1 px-3 flex mx-auto appearance-none text-center">
              {"Comment" |> str}
            </button> :
            ReasonReact.null
        }
      </DisablingCover>
    </div>
  </div>;
};