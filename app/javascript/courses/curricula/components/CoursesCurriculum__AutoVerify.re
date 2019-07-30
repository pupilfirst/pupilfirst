[@bs.config {jsx: 3}];

let str = React.string;

open CoursesCurriculum__Types;
module TargetStatus = CoursesCurriculum__TargetStatus;

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

  window
  |> Webapi.Dom.Window.open_(~url=link, ~name="_blank", ~features="")
  |> ignore;
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

let completeButtonText = (title, iconClasses) =>
  <span> <FaIcon classes={iconClasses ++ " mr-2"} /> {title |> str} </span>;

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
    className="flex rounded text-lg justify-center w-full font-bold p-4 text-blue-500 bg-blue-100  "
    onClick={
      createAutoVerifySubmission(
        authenticityToken,
        target,
        linkToComplete,
        setSaving,
        addSubmissionCB,
      )
    }>
    {
      switch (saving, linkToComplete) {
      | (true, _) =>
        completeButtonText("Saving", "fal fa-spinner-third fa-spin")
      | (false, Some(_)) =>
        completeButtonText("Visit Link To Complete", "fas fa-external-link")
      | (false, None) =>
        completeButtonText("Mark As Complete", "fas fa-check-square")
      }
    }
  </button>;

let statusBar = (string, linkToComplete) => {
  let defaultClasses = "font-bold p-4 flex w-full items-center text-green-500 bg-green-100 justify-center";
  let message =
    <div className="flex items-center">
      <span className="fa-stack text-lg mr-1 text-green-500">
        <i className="fas fa-badge fa-stack-2x" />
        <i className="fas fa-check fa-stack-1x fa-inverse" />
      </span>
      <span> {string |> str} </span>
    </div>;
  let visitLink = link =>
    <a className="text-right w-full" href=link target="_blank">
      <i className="fas fa-external-link mr-2" />
      {"Visit Link" |> str}
    </a>;

  <div className=defaultClasses>
    message
    {
      switch (linkToComplete) {
      | Some(link) => visitLink(link)
      | None => React.null
      }
    }
  </div>;
};

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
      | _ => statusBar("Completed", linkToComplete)
      }
    }
  </div>;
};
