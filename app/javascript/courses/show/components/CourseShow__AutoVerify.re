[@bs.config {jsx: 3}];

let str = React.string;

open CourseShow__Types;

module AutoVerifySubmissionQuery = [%graphql
  {|
   mutation($targetId: ID!) {
    autoVerifySubmission(targetId: $targetId){
      submissionDetails{
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
       switch (response##autoVerifySubmission##submissionDetails) {
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

[@react.component]
let make = (~target, ~targetDetails, ~authenticityToken) => {
  let (saving, setSaving) = React.useState(() => false);
  let linkToComplete = targetDetails |> TargetDetails.linkToComplete;
  <div>
    <DisablingCover disabled=saving>
      <button
        className="btn btn-success btn-large w-full"
        onClick={
          createAutoVerifySubmission(
            authenticityToken,
            target,
            linkToComplete,
            setSaving,
          )
        }>
        {
          (
            switch (linkToComplete) {
            | Some(_) => "Visit Link To Complete"
            | None => "Mark As Complete"
            }
          )
          |> str
        }
      </button>
    </DisablingCover>
  </div>;
};