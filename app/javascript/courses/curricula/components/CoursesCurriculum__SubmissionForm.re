[@bs.config {jsx: 3}];

open CoursesCurriculum__Types;

let str = React.string;

type formState =
  | TypingLink
  | Attaching
  | Saving
  | Incomplete
  | Ready;

let buttonContents = formState => {
  let icon =
    switch (formState) {
    | TypingLink => <FaIcon classes="fas fa-keyboard mr-2" />
    | Attaching
    | Saving => <FaIcon classes="fas fa-spinner fa-spin mr-2" />
    | Incomplete
    | Ready => <FaIcon classes="fas fa-cloud-upload-alt mr-2" />
    };

  let text =
    (
      switch (formState) {
      | TypingLink => "Finish adding link..."
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
  | TypingLink
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
  attachments: list(string),
};

type action =
  | SetTypingLink(bool)
  | UpdateFormState(formState)
  | UpdateDescription(string)
  | AttachFile(id, filename)
  | AttachUrl(url)
  | RemoveAttachment(string);

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
  | SetTypingLink(typing) => {
      ...state,
      formState:
        switch (typing, state.formState) {
        | (typing, Incomplete)
        | (typing, Ready) => typing ? TypingLink : Ready
        | (typing, TypingLink) =>
          typing ? TypingLink : descriptionToFormState(state.description)
        | (_, otherState) => otherState
        },
    }
  | UpdateDescription(description) => {
      ...state,
      description,
      formState:
        switch (state.formState) {
        | Incomplete
        | Ready => descriptionToFormState(description)
        | otherState => otherState
        },
    }
  | AttachFile(id, filename) => {
      ...state,
      attachments: [id, ...state.attachments],
      formState: descriptionToFormState(state.description),
    }
  | AttachUrl(url) => state
  | RemoveAttachment(attachment) => {
      ...state,
      attachments: state.attachments |> List.filter(a => a != attachment),
    }
  };

let isBusy = formState =>
  switch (formState) {
  | Attaching
  | Saving => true
  | TypingLink
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
    ~description=state.description,
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
  | TypingLink
  | Attaching
  | Incomplete
  | Ready => false
  };

[@react.component]
let make =
    (~authenticityToken, ~target, ~addSubmissionCB, ~preview, ~checklist) => {
  let (state, send) = React.useReducer(reducer, initialState);

  <div className="bg-gray-100 pt-6 px-4 pb-2 mt-4 border rounded-lg">
    {checklist
     |> Array.mapi((index, checklistItem) => {
          let key = index |> string_of_int;
          <div key>
            <label
              htmlFor="submission-description" className="font-semibold pl-1">
              {(checklistItem |> TargetChecklistItem.title)
               ++ (
                 checklistItem |> TargetChecklistItem.optional
                   ? " (optional)" : ""
               )
               |> str}
            </label>
            {switch (checklistItem |> TargetChecklistItem.kind) {
             | Files =>
               state.attachments |> List.length >= 3
                 ? React.null
                 : <CoursesCurriculum__FileForm
                     authenticityToken
                     attachingCB={() => send(UpdateFormState(Attaching))}
                     attachFileCB={(id, filename) =>
                       send(AttachFile(id, filename))
                     }
                     preview
                   />
             | Link =>
               <input
                 id="attachment_url"
                 type_="text"
                 placeholder="Type full URL starting with https://..."
                 className="mt-2 cursor-pointer truncate h-10 border border-grey-400 flex px-4 items-center font-semibold rounded text-sm flex-grow mr-2"
               />
             | ShortText =>
               <input
                 className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                 id={"short-text-" ++ key}
                 type_="text"
                 maxLength=250
               />
             | LongText =>
               <textarea
                 id="submission-description"
                 maxLength=1000
                 disabled={isDescriptionDisabled(state.formState)}
                 value={state.description}
                 className="h-40 w-full rounded-lg mt-4 p-4 border border-gray-400 focus:outline-none focus:border-gray-500 rounded-lg"
                 placeholder="Describe your work, or leave notes to the reviewer here. If you are submitting a URL, or need to attach a file, use the controls below to add them."
                 onChange={updateDescription(send)}
               />
             | MultiChoice(_choices) =>
               <input
                 className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                 id={"short-text-" ++ key}
                 type_="text"
                 maxLength=250
               />
             | Statement =>
               <input
                 className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                 id={"statement-" ++ key}
                 type_="text"
                 maxLength=250
               />
             }}
          </div>;
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
