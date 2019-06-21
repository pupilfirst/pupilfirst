[@bs.config {jsx: 3}];

open CourseShow__Types;

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
    | Saving => <FaIcon classes="fal fa-spinner-third fa-spin mr-2" />
    | Incomplete
    | Ready => <FaIcon classes="fas fa-cloud-upload mr-2" />
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
  description: string,
  attachments: list(SubmissionAttachment.attachment),
};

type action =
  | UpdateFormState(formState)
  | UpdateDescription(string)
  | AttachFile(id, filename)
  | AttachUrl(url)
  | RemoveAttachment(SubmissionAttachment.attachment);

let initialState = {formState: Incomplete, description: "", attachments: []};

let descriptionToFormState = description =>
  description |> String.trim == "" ? Incomplete : Ready;

let updateDescription = (send, event) => {
  let value = ReactEvent.Form.target(event)##value;
  send(UpdateDescription(value));
};

let reducer = (state, action) =>
  switch (action) {
  | UpdateFormState(formState) => {...state, formState}
  | UpdateDescription(description) => {
      ...state,
      description,
      formState:
        switch (state.formState) {
        | Incomplete
        | Ready => descriptionToFormState(description)
        | Attaching => Attaching
        | Saving => Saving
        },
    }
  | AttachFile(id, filename) => {
      ...state,
      attachments: [
        SubmissionAttachment.File(
          id,
          filename,
          "/timeline_event_files/" ++ id ++ "/download",
        ),
        ...state.attachments,
      ],
      formState: descriptionToFormState(state.description),
    }
  | AttachUrl(url) =>
    let attachment =
      state.attachments
      |> ListUtils.findOpt(attachment =>
           switch (attachment) {
           | SubmissionAttachment.File(_, _, _) => false
           | Link(storedUrl) => url == storedUrl
           }
         );

    switch (attachment) {
    | Some(_attachment) => state
    | None => {...state, attachments: [Link(url), ...state.attachments]}
    };
  | RemoveAttachment(attachment) => {
      ...state,
      attachments: state.attachments |> List.filter(a => a != attachment),
    }
  };

let removeAttachment = (attachment, send, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(RemoveAttachment(attachment));
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

let attachmentValues = attachments =>
  attachments
  |> List.map(attachment =>
       switch (attachment) {
       | SubmissionAttachment.File(id, _, _) => id
       | Link(url) => url
       }
     )
  |> Array.of_list;

let submit = (state, send, authenticityToken, target, addSubmissionCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  send(UpdateFormState(Saving));

  let (fileAttachments, linkAttachments) =
    state.attachments
    |> List.partition(attachment =>
         switch (attachment) {
         | SubmissionAttachment.File(_, _, _) => true
         | Link(_) => false
         }
       );

  let fileIds = attachmentValues(fileAttachments);
  let links = attachmentValues(linkAttachments);

  CreateSubmissionQuery.make(
    ~targetId=target |> Target.id,
    ~description=state.description,
    ~fileIds,
    ~links,
    (),
  )
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       switch (response##createSubmission##submission) {
       | Some(submission) =>
         Js.log(submission##id);
         let newSubmission =
           Submission.make(
             ~id=submission##id,
             ~description=state.description |> String.trim,
             ~createdAt=submission##createdAt,
             ~status=Submission.Pending,
           );
         let newAttachments =
           state.attachments
           |> List.map(attachment =>
                SubmissionAttachment.make(submission##id, attachment)
              );

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

[@react.component]
let make = (~authenticityToken, ~target, ~addSubmissionCB) => {
  let (state, send) = React.useReducer(reducer, initialState);

  <div className="bg-gray-200 pt-6 px-4 pb-2 mt-4 shadow rounded-lg">
    <h5 className="pl-1"> {"Work on your submission" |> str} </h5>
    <textarea
      maxLength=1000
      disabled={isDescriptionDisabled(state.formState)}
      value={state.description}
      className="h-40 w-full rounded-lg mt-4 p-4 border rounded-lg"
      placeholder="Describe your work, attach any links or files, and then hit submit!"
      onChange={updateDescription(send)}
    />
    <CoursesShow__Attachments
      attachments={state.attachments}
      removeAttachmentCB={
        Some(attachment => send(RemoveAttachment(attachment)))
      }
    />
    {
      state.attachments |> List.length >= 3 ?
        React.null :
        <CourseShow__NewAttachment
          authenticityToken
          attachingCB={() => send(UpdateFormState(Attaching))}
          attachFileCB={(id, filename) => send(AttachFile(id, filename))}
          attachUrlCB={url => send(AttachUrl(url))}
          disabled={isBusy(state.formState)}
        />
    }
    <div className="flex mt-3 justify-end">
      <button
        onClick={
          submit(state, send, authenticityToken, target, addSubmissionCB)
        }
        disabled={isButtonDisabled(state.formState)}
        className="btn btn-primary flex justify-center flex-grow md:flex-grow-0">
        {buttonContents(state.formState)}
      </button>
    </div>
  </div>;
};
