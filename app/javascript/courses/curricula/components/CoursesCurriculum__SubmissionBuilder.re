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

type state = {
  formState,
  checklist: array(ChecklistItem.t),
};

type action =
  | UpdateFormState(formState)
  | UpdateResponse(array(ChecklistItem.t));

let initialState = checklist => {
  formState: Ready,
  checklist: ChecklistItem.makeEmpty(checklist),
};

let reducer = (state, action) =>
  switch (action) {
  | UpdateFormState(formState) => {...state, formState}
  | UpdateResponse(checklist) => {checklist, formState: Ready}
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
    | Saving
    | Incomplete => true
    | Ready => false
    }
  )
  || !(state.checklist |> ChecklistItem.validChecklist);
};

let submit = (state, send, target, addSubmissionCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  send(UpdateFormState(Saving));

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

let updateResult = (state, send, index, result) => {
  send(
    UpdateResponse(
      state.checklist |> ChecklistItem.updateResult(index, result),
    ),
  );
};

let buttonClasses = checklist => {
  "flex mt-3 "
  ++ (
    switch (checklist) {
    | [||] => "justify-center"
    | _ => " justify-end"
    }
  );
};

let attaching = (send, bool) => {
  send(bool ? UpdateFormState(Attaching) : UpdateFormState(Ready));
};

let statusText = formState => {
  switch (formState) {
  | Attaching => "Attaching..."
  | Saving => "Submitting..."
  | Incomplete
  | Ready => "Submit"
  };
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
                  attachingCB={attaching(send)}
                  preview
                />
              })
           |> React.array}
      <div className={buttonClasses(state.checklist)}>
        <button
          onClick={submit(state, send, target, addSubmissionCB)}
          disabled={isButtonDisabled(state) || preview}
          className="btn btn-primary flex justify-center flex-grow md:flex-grow-0">
          {buttonContents(state.formState)}
        </button>
      </div>
    </DisablingCover>
  </div>;
};
