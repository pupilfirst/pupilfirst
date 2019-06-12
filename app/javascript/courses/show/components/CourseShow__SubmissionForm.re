[@bs.config {jsx: 3}];

open CourseShow__Types;

let str = React.string;

type buttonState =
  | Attaching
  | Saving
  | Incomplete
  | Ready;

let buttonContents = buttonState => {
  let icon =
    switch (buttonState) {
    | Attaching
    | Saving => <FaIcon classes="fal fa-spinner-third fa-spin mr-2" />
    | Incomplete
    | Ready => <FaIcon classes="fas fa-cloud-upload mr-2" />
    };

  let text =
    (
      switch (buttonState) {
      | Attaching => "Attaching..."
      | Saving => "Submitting..."
      | Incomplete
      | Ready => "Submit"
      }
    )
    |> str;

  <span> icon text </span>;
};

let isButtonDisabled = buttonState =>
  switch (buttonState) {
  | Attaching
  | Saving
  | Incomplete => true
  | Ready => false
  };

type id = string;
type filename = string;
type url = string;

type attachment =
  | Link(url)
  | File(id, filename);

type state = {
  buttonState,
  description: string,
  attachments: list(attachment),
};

type action =
  | UpdateButtonState(buttonState)
  | UpdateDescription(string, buttonState)
  | AddAttachment(attachment)
  | RemoveAttachment(attachment)
  | ResetForm;

let initialState = {
  buttonState: Incomplete,
  description: "",
  attachments: [],
};

let reducer = (state, action) =>
  switch (action) {
  | UpdateButtonState(buttonState) => {...state, buttonState}
  | UpdateDescription(description, buttonState) => {
      ...state,
      description,
      buttonState,
    }
  | AddAttachment(attachment) => {
      ...state,
      attachments: [attachment, ...state.attachments],
    }
  | RemoveAttachment(attachment) => {
      ...state,
      attachments: state.attachments |> List.filter(a => a != attachment),
    }
  | ResetForm => initialState
  };

let updateDescription = (send, event) => {
  let value = ReactEvent.Form.target(event)##value;
  let buttonState = value |> String.trim == "" ? Incomplete : Ready;
  send(UpdateDescription(value, buttonState));
};

let attachments = (state, send) =>
  switch (state.attachments) {
  | [] => React.null
  | attachments =>
    <div className="flex flex-wrap">
      {
        attachments
        |> List.map(attachment =>
             switch (attachment) {
             | Link(url) =>
               <span
                 className="mt-2 mr-2 flex items-center border-2 border-blue-200 bg-blue-200 rounded-lg">
                 <span className="flex p-2 bg-blue-200 cursor-pointer">
                   <i className="fas fa-times" />
                 </span>
                 <span
                   className="bg-blue-100 rounded px-2 py-1 truncate rounded-lg">
                   <span className="text-xs font-semibold text-primary-600">
                     {url |> str}
                   </span>
                 </span>
               </span>
             | File(id, filename) =>
               <span
                 className="mt-2 mr-2 flex items-center border-2 border-primary-200 bg-primary-200 rounded-lg">
                 <span className="flex p-2 bg-primary-200 cursor-pointer">
                   <i className="fas fa-times" />
                 </span>
                 <span
                   className="bg-primary-100 rounded px-2 py-1 truncate rounded-lg">
                   <span className="text-xs font-semibold text-primary-600">
                     {filename |> str}
                   </span>
                 </span>
               </span>
             }
           )
        |> Array.of_list
        |> React.array
      }
    </div>
  };

[@react.component]
let make = (~authenticityToken, ~target) => {
  let (state, send) = React.useReducer(reducer, initialState);

  <div className="bg-gray-200 pt-6 px-4 pb-2 mt-4 shadow rounded-lg">
    <h5 className="pl-1"> {"Work on your submission" |> str} </h5>
    <textarea
      value={state.description}
      className="h-40 w-full rounded-lg mt-4 p-4 border rounded-lg"
      placeholder="Describe your work, attach any links or files, and then hit submit!"
      onChange={updateDescription(send)}
    />
    {attachments(state, send)}
    <CourseShow__NewAttachment
      authenticityToken
      attachingCB={() => send(UpdateButtonState(Attaching))}
      attachFileCB={
        (id, filename) => send(AddAttachment(File(id, filename)))
      }
    />
    <div className="flex mt-3 justify-end">
      <button
        disabled={isButtonDisabled(state.buttonState)}
        className="btn btn-primary flex justify-center flex-grow md:flex-grow-0">
        {buttonContents(state.buttonState)}
      </button>
    </div>
  </div>;
};
