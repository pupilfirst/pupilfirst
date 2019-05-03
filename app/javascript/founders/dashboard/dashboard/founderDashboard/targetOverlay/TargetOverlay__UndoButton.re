[@bs.config {jsx: 3}]
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
  event |> ReactEvent.Mouse.preventDefault;
};

let buttonContents = status =>
  switch (status) {
  | Undoing =>
    <span>
      <i className="fa fa-spinner fa-pulse mr-2" />
      {"Undoing..." |> str}
    </span>
  | Pending => <span> <i className="fa fa-undo mr-2" /> {"Undo" |> str} </span>
  | Errored =>
    <span>
      <i className="fa fa-exclamation-triangle mr-2" />
      {"Error!" |> str}
    </span>
  };

let isDisabled = status =>
  switch (status) {
  | Undoing
  | Errored => true
  | Pending => false
  };

let buttonStyle = status => {
  let cursor =
    switch (status) {
    | Undoing => "wait"
    | Errored => "not-allowed"
    | Pending => "pointer"
    };

  ReactDOMRe.Style.make(~cursor, ());
};

[@react.component]
let make = (~authenticityToken, ~undoSubmissionCB, ~targetId) => {
  let (status, setStatus) = React.useState(() => Pending);
  <button
    disabled={status |> isDisabled}
    className="btn btn-md btn-danger text-uppercase btn-timeline-builder"
    style={buttonStyle(status)}
    onClick={
      handleClick(targetId, setStatus, undoSubmissionCB, authenticityToken)
    }>
    {buttonContents(status)}
  </button>;
};