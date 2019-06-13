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

let handleSuccess = (details, linkToComplete) =>
  switch (linkToComplete) {
  | Some(link) => Notification.success("Forward", link)
  | None => Notification.success("Success", details##description)
  };

let createAutoVerifySubmission =
    (authenticityToken, target, linkToComplete, setSaving, event) => {
  setSaving(_ => true);
  AutoVerifySubmissionQuery.make(~targetId=target |> Target.id, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       switch (response##autoVerifySubmission##submission) {
       | Some(details) => handleSuccess(details, linkToComplete)

       | None =>
         Notification.error(
           "Something went wrong",
           "Please refresh the page and try again",
         )
       };
       Js.Promise.resolve();
     })
  |> ignore;
};

let autoVerify =
    (target, linkToComplete, saving, setSaving, authenticityToken) =>
  <button
    disabled=saving
    className="btn btn-success btn-large w-full"
    onClick={
      createAutoVerifySubmission(
        authenticityToken,
        target,
        linkToComplete,
        setSaving,
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

let statusBadge = (string, complete) => {
  let bgClasses = complete ? "bg-green-500" : "bg-gray-500";
  <div
    className={
      "flex text-white rounded text-lg font-semibold justify-center p-2 "
      ++ bgClasses
    }>
    {string |> str}
  </div>;
};

[@react.component]
let make = (~target, ~targetDetails, ~authenticityToken, ~targetStatus) => {
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
        )
      | Locked(lockReason) =>
        statusBadge(lockReason |> TargetStatus.lockReasonToString, false)
      | _ => statusBadge("Completed", true)
      }
    }
  </div>;
};
