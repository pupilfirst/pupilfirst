[@bs.config {jsx: 3}];

open CoursesCurriculum__Types;

let str = React.string;

type formState =
  | Attaching
  | Saving
  | Ready;

let buttonContents = (formState, checklist) => {
  let icon =
    switch (formState) {
    | Attaching
    | Saving => <FaIcon classes="fas fa-spinner fa-pulse mr-2" />
    | Ready => <FaIcon classes="fas fa-cloud-upload-alt mr-2" />
    };

  let text =
    (
      switch (formState) {
      | Attaching => "Attaching..."
      | Saving => "Submitting..."
      | Ready => checklist |> ArrayUtils.isEmpty ? "Complete" : "Submit"
      }
    )
    |> str;

  <span> icon text </span>;
};

type state = {
  formState,
  checklist: array(ChecklistItem.t),
};

type action =
  | SetAttaching
  | SetSaving
  | SetReady
  | UpdateResponse(array(ChecklistItem.t));

let initialState = checklist => {
  formState: Ready,
  checklist: ChecklistItem.fromTargetChecklistItem(checklist),
};

let reducer = (state, action) =>
  switch (action) {
  | SetAttaching => {...state, formState: Attaching}
  | SetSaving => {...state, formState: Saving}
  | SetReady => {...state, formState: Ready}
  | UpdateResponse(checklist) => {checklist, formState: Ready}
  };

let isBusy = formState =>
  switch (formState) {
  | Attaching
  | Saving => true
  | Ready => false
  };

module CreateSubmissionQuery = [%graphql
  {|
  mutation($targetId: ID!, $checklist: JSON!, $fileIds: [ID!]!) {
    createSubmission(targetId: $targetId, checklist: $checklist, fileIds: $fileIds) {
      submission {
        id
        createdAt
      }
    }
  }
  |}
];

let isButtonDisabled = state => {
  (
    switch (state.formState) {
    | Attaching
    | Saving => true
    | Ready => false
    }
  )
  || !(state.checklist |> ChecklistItem.validChecklist);
};

let submit = (state, send, target, addSubmissionCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  send(SetSaving);

  let fileIds = state.checklist |> ChecklistItem.fileIds;
  let checklist = state.checklist |> ChecklistItem.encodeArray;

  CreateSubmissionQuery.make(
    ~targetId=target |> Target.id,
    ~fileIds,
    ~checklist,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       switch (response##createSubmission##submission) {
       | Some(submission) =>
         let files = state.checklist |> ChecklistItem.makeFiles;
         let submissionChecklist =
           checklist
           |> Json.Decode.array(SubmissionChecklistItem.decode(files));
         let newSubmission =
           Submission.make(
             ~id=submission##id,
             ~createdAt=submission##createdAt,
             ~status=Submission.Pending,
             ~checklist=submissionChecklist,
           );
         let newFiles = submission##id;
         addSubmissionCB(newSubmission, newFiles);
       | None =>
         /* Enable the form again in case of a validation failure. */
         send(SetReady)
       };
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(_error => {
       /* Enable the form again in case of server crash. */
       send(SetReady);
       Js.Promise.resolve();
     })
  |> ignore;
};

let updateResult = (state, send, index, result) => {
  send(
    UpdateResponse(
      state.checklist |> ChecklistItem.updateResultAtIndex(index, result),
    ),
  );
};

let buttonClasses = checklist =>
  "flex mt-3 "
  ++ (checklist |> ArrayUtils.isEmpty ? "justify-center" : "justify-end");

let setAttaching = (send, bool) => {
  send(bool ? SetAttaching : SetReady);
};

let statusText = formState => {
  switch (formState) {
  | Attaching => "Attaching..."
  | Saving => "Submitting..."
  | Ready => "Submit"
  };
};

let tooltipText = (disabled, preview) =>
  if (preview) {
    "You are accessing the preview mode for this course";
  } else if (disabled) {
    "Please complete all the required steps to submit this target";
  } else {
    "Submit for review";
  };

[@react.component]
let make = (~target, ~addSubmissionCB, ~preview, ~checklist) => {
  let (state, send) = React.useReducer(reducer, initialState(checklist));
  <div className="bg-gray-100 p-4 mt-4 border rounded-lg">
    <DisablingCover
      disabled={isBusy(state.formState)}
      message={statusText(state.formState)}>
      {state.checklist |> ArrayUtils.isEmpty
         ? <div className="text-center">
             {"This target has no actions. Click submit to complete the target"
              |> str}
           </div>
         : state.checklist
           |> Array.mapi((index, checklistItem) => {
                <CoursesCurriculum__SubmissionItem
                  key={index |> string_of_int}
                  index
                  checklistItem
                  updateResultCB={updateResult(state, send, index)}
                  attachingCB={setAttaching(send)}
                  preview
                />
              })
           |> React.array}
      <div className={buttonClasses(state.checklist)}>
        <Tooltip tip={tooltipText(isButtonDisabled(state), preview) |> str}>
          <button
            onClick={submit(state, send, target, addSubmissionCB)}
            disabled={isButtonDisabled(state) || preview}
            className="btn btn-primary flex justify-center flex-grow md:flex-grow-0">
            {buttonContents(state.formState, checklist)}
          </button>
        </Tooltip>
      </div>
    </DisablingCover>
  </div>;
};
