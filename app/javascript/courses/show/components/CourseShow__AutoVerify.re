[@bs.config {jsx: 3}];

let str = React.string;

open CourseShow__Types;
module TargetStatus = CourseShow__TargetStatus;

module AutoVerifySubmissionQuery = [%graphql
  {|
   mutation($targetId: ID!) {
    autoVerifySubmission(targetId: $targetId){
      submission{
        id
        description
        createdAt
      }
     }
   }
 |}
];

let redirect = link => {
  let window = Webapi.Dom.window;
  link |> Webapi.Dom.Window.setLocation(window);
};

let handleSuccess = (submission, linkToComplete, addSubmissionCB) => {
  addSubmissionCB(
    Submission.make(
      ~id=submission##id,
      ~description=submission##description,
      ~createdAt=submission##createdAt,
      ~status=Submission.MarkedAsComplete,
    ),
  );
  switch (linkToComplete) {
  | Some(link) => redirect(link)
  | None => ()
  };
};

let createAutoVerifySubmission =
    (
      authenticityToken,
      target,
      linkToComplete,
      setSaving,
      addSubmissionCB,
      event,
    ) => {
  event |> ReactEvent.Mouse.preventDefault;
  setSaving(_ => true);
  AutoVerifySubmissionQuery.make(~targetId=target |> Target.id, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       switch (response##autoVerifySubmission##submission) {
       | Some(details) =>
         handleSuccess(details, linkToComplete, addSubmissionCB)
       | None => setSaving(_ => false)
       };
       Js.Promise.resolve();
     })
  |> ignore;
};

let autoVerify =
    (
      target,
      linkToComplete,
      saving,
      setSaving,
      authenticityToken,
      addSubmissionCB,
    ) =>
  <button
    disabled=saving
    className="flex text-white rounded text-lg font-semibold justify-center btn btn-success btn-large w-full"
    onClick={
      createAutoVerifySubmission(
        authenticityToken,
        target,
        linkToComplete,
        setSaving,
        addSubmissionCB,
      )
    }>
    {saving ? <i className="fal fa-spinner-third fa-spin" /> : React.null}
    <span className="ml-2">
      {
        (
          switch (saving, linkToComplete) {
          | (true, _) => "Saving"
          | (false, Some(_)) => "Visit Link To Complete"
          | (false, None) => "Mark As Complete"
          }
        )
        |> str
      }
    </span>
  </button>;

let statusBadge = (string, complete) =>
  <div
    className="flex text-white rounded text-lg font-semibold justify-center p-2 bg-green-500">
    {string |> str}
  </div>;

[@react.component]
let make =
    (
      ~target,
      ~targetDetails,
      ~authenticityToken,
      ~targetStatus,
      ~addSubmissionCB,
    ) => {
  let (saving, setSaving) = React.useState(() => false);
  let linkToComplete = targetDetails |> TargetDetails.linkToComplete;
  <div className="mt-4" id="auto-verify-target">
    {
      switch (targetStatus |> TargetStatus.status) {
      | Pending =>
        autoVerify(
          target,
          linkToComplete,
          saving,
          setSaving,
          authenticityToken,
          addSubmissionCB,
        )
      | Locked(_) => React.null
      | _ => statusBadge("Completed", true)
      }
    }
  </div>;
};
