[@bs.config {jsx: 3}];

let str = React.string;

module DeleteSubmissionQuery = [%graphql
  {|
  mutation($targetId: ID!) {
    undoSubmission(targetId: $targetId) {
      success
    }
  }
  |}
];

type status =
  | Pending
  | Undoing
  | Errored;

let handleClick =
    (targetId, setStatus, undoSubmissionCB, authenticityToken, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  if (Webapi.Dom.(
        window
        |> Window.confirm("Are you sure you want to delete this submission?")
      )) {
    setStatus(_ => Undoing);

    DeleteSubmissionQuery.make(~targetId, ())
    |> GraphqlQuery.sendQuery(authenticityToken)
    |> Js.Promise.then_(response => {
         if (response##undoSubmission##success) {
           undoSubmissionCB();
         } else {
           Notification.notice(
             "Could not undo submission",
             "Please reload the page and check the status of the submission before trying again.",
           );
           setStatus(_ => Errored);
         };
         Js.Promise.resolve();
       })
    |> Js.Promise.catch(_ => {
         Notification.error(
           "Unexpected Error",
           "An unexpected error occured, and our team has been notified about this. Please reload the page before trying again.",
         );
         setStatus(_ => Errored);
         Js.Promise.resolve();
       })
    |> ignore;
  } else {
    ();
  };
};

let buttonContents = status =>
  switch (status) {
  | Undoing =>
    <span>
      <FaIcon classes="fal fa-spinner-third fa-spin mr-2" />
      {"Undoing..." |> str}
    </span>
  | Pending =>
    <span>
      <FaIcon classes="fas fa-undo mr-2" />
      <span className="hidden md:inline"> {"Undo sumission" |> str} </span>
      <span className="md:hidden"> {"Undo" |> str} </span>
    </span>
  | Errored =>
    <span>
      <FaIcon classes="fas fa-exclamation-triangle mr-2" />
      {"Error!" |> str}
    </span>
  };

let isDisabled = status =>
  switch (status) {
  | Undoing
  | Errored => true
  | Pending => false
  };

let buttonClasses = status => {
  let classes = "btn btn-small btn-danger cursor-";

  classes
  ++ (
    switch (status) {
    | Undoing => "wait"
    | Errored => "not-allowed"
    | Pending => "pointer"
    }
  );
};

[@react.component]
let make = (~authenticityToken, ~undoSubmissionCB, ~targetId) => {
  let (status, setStatus) = React.useState(() => Pending);
  <button
    disabled={status |> isDisabled}
    className={buttonClasses(status)}
    onClick={
      handleClick(targetId, setStatus, undoSubmissionCB, authenticityToken)
    }>
    {buttonContents(status)}
  </button>;
};
