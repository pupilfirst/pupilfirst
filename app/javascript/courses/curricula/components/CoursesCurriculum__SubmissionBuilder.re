[@bs.config {jsx: 3}];

open CoursesCurriculum__Types;

let str = React.string;

type formState =
  | Attaching
  | Saving
  | Incomplete
  | Ready;

let buttonContents = formState => {
  let icon =
    switch (formState) {
    | Attaching
    | Saving => <FaIcon classes="fas fa-spinner fa-spin mr-2" />
    | Incomplete
    | Ready => <FaIcon classes="fas fa-cloud-upload-alt mr-2" />
    };

  let text =
    (
      switch (formState) {
      | Attaching => "Attaching..."
      | Saving => "Submitting..."
      | Incomplete
      | Ready => "Submit"
      }
    )
    |> str;

  <span> icon text </span>;
};

let isButtonDisabled = formState =>
  switch (formState) {
  | Attaching
  | Saving
  | Incomplete => true
  | Ready => false
  };

type id = string;
type filename = string;
type url = string;

type state = {
  formState,
  response: array(ChecklistResponseItem.t),
};

type action =
  | UpdateFormState(formState)
  | UpdateResponse(array(ChecklistResponseItem.t));

let initialState = checklist => {
  formState: Incomplete,
  response: ChecklistResponseItem.makeEmpty(checklist),
};

// let descriptionToFormState = description =>
//   description |> String.trim == "" ? Incomplete : Ready;

// let updateDescription = (send, event) => {
//   let value = ReactEvent.Form.target(event)##value;
//   send(UpdateDescription(value));
// };

let reducer = (state, action) =>
  switch (action) {
  | UpdateFormState(formState) => {...state, formState}
  | UpdateResponse(response) => {...state, response}
  };

let isBusy = formState =>
  switch (formState) {
  | Attaching
  | Saving => true
  | Incomplete
  | Ready => false
  };

module CreateSubmissionQuery = [%graphql
  {|
  mutation($targetId: ID!, $description: String!, $fileIds: [ID!]!, $links: [String!]!) {
    createSubmission(targetId: $targetId, description: $description, fileIds: $fileIds, links: $links) {
      submission {
        id
        createdAt
      }
    }
  }
  |}
];

let attachmentValues = attachments => attachments |> Array.of_list;

let submit = (state, send, target, addSubmissionCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  send(UpdateFormState(Saving));

  // let (fileAttachments, linkAttachments) =
  //   state.attachments
  //   |> List.partition(attachment =>
  //        switch (attachment) {
  //        | SubmissionAttachment.File(_, _, _) => true
  //        | Link(_) => false
  //        }
  //      );

  let fileIds = [||];
  // let links = attachmentValues(linkAttachments);
  let links = [|"", ""|];
  CreateSubmissionQuery.make(
    ~targetId=target |> Target.id,
    ~description="",
    ~fileIds,
    ~links,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       switch (response##createSubmission##submission) {
       | Some(submission) =>
         Js.log(submission##id);
         let newSubmission =
           Submission.make(
             ~id=submission##id,
             ~createdAt=submission##createdAt,
             ~status=Submission.Pending,
           );
         let newAttachments = submission##id;

         Js.log("Calling addSubmissionCB in SubmissionForm");
         addSubmissionCB(newSubmission, newAttachments);
       | None =>
         /* Enable the form again in case of a validation failure. */
         send(UpdateFormState(Ready))
       };
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_error => {
       /* Enable the form again in case of server crash. */
       send(UpdateFormState(Ready));
       Js.Promise.resolve();
     })
  |> ignore;
};

let isDescriptionDisabled = formState =>
  switch (formState) {
  | Saving => true
  | Attaching
  | Incomplete
  | Ready => false
  };

let updateResponse = (state, send, index, result) => {
  send(
    UpdateResponse(
      state.response |> ChecklistResponseItem.updateResult(index, result),
    ),
  );
};

[@react.component]
let make =
    (~authenticityToken, ~target, ~addSubmissionCB, ~preview, ~checklist) => {
  let (state, send) = React.useReducer(reducer, initialState(checklist));

  <div className="bg-gray-100 pt-6 px-4 pb-2 mt-4 border rounded-lg">
    {state.response
     |> Array.mapi((index, responseItem) => {
          let key = index |> string_of_int;
          let question = responseItem |> ChecklistResponseItem.question;
          <CoursesCurriculum__SubmissionItem
            targetChecklistItem={
              responseItem |> ChecklistResponseItem.question
            }
          />;
        })
     |> React.array}
    <div className="flex mt-3 justify-end">
      <button
        onClick={submit(state, send, target, addSubmissionCB)}
        disabled={isButtonDisabled(state.formState) || preview}
        className="btn btn-primary flex justify-center flex-grow md:flex-grow-0">
        {buttonContents(state.formState)}
      </button>
    </div>
  </div>;
};
