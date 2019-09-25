[@bs.config {jsx: 3}];
[%bs.raw {|require("./MarkdownEditor.css")|}];

module DraftEditor = {
  type editorState;

  [@bs.module "./ReactDraftEditor"] [@react.component]
  external make:
    (
      ~content: string,
      ~onChange: string => unit,
      ~ariaLabelledBy: string=?,
      ~placeholder: string=?,
      ~command: string=?,
      ~commandAt: string=?
    ) =>
    React.element =
    "default";
};

type command =
  | Bold
  | Italic;

type commandPair = {
  command: option(command),
  commandAt: option(string),
};

type defaultView =
  | Preview
  | Edit;

let str = React.string;

type state = {
  description: string,
  preview: bool,
  commandPair,
};

type action =
  | UpdateDescription(string)
  | TogglePreview
  | SetCommand(command);

let reducer = (state, action) =>
  switch (action) {
  | UpdateDescription(description) => {...state, description}
  | TogglePreview => {
      ...state,
      preview: !state.preview,
      commandPair: {
        command: None,
        commandAt: None,
      },
    }
  | SetCommand(command) =>
    let commandAt = Js.Date.now() |> Js.Float.toString;
    let commandPair = {command: Some(command), commandAt: Some(commandAt)};
    {...state, commandPair};
  };

let updateDescription = (value, description, send, updateDescriptionCB) =>
  value == description ?
    () :
    {
      send(UpdateDescription(description));
      updateDescriptionCB(description);
    };

type previewButtonPosition =
  | PositionRight
  | PositionLeft;

let commandIcon = command =>
  switch (command) {
  | Bold => <i className="fas fa-bold" />
  | Italic => <i className="fas fa-italic" />
  };

let commandToTitle = command =>
  switch (command) {
  | Bold => "Bold"
  | Italic => "Italic"
  };

let commandToString = command =>
  switch (command) {
  | Bold => "bold"
  | Italic => "italic"
  };

let handleCommandClick = (command, send, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  send(SetCommand(command));
};

let buttons = (state, send, previewButtonPosition) => {
  let classes = "markdown-button-group__button hover:bg-primary-100 hover:text-primary-400 focus:outline-none focus:text-primary-600";

  let previewOrEditButton =
    (
      switch (state.description) {
      | "" => React.null
      | _someDescription =>
        <button
          key="preview-button"
          className=classes
          onClick=(
            event => {
              ReactEvent.Mouse.preventDefault(event);
              send(TogglePreview);
            }
          )>
          <FaIcon classes={state.preview ? "fab fa-markdown" : "far fa-eye"} />
          <span className="ml-2">
            {(state.preview ? "Edit Markdown" : "Preview") |> str}
          </span>
        </button>
      }
    )
    |> Array.make(1);

  let styleButtons =
    [|Bold, Italic|]
    |> Array.map(command =>
         <button
           className=classes
           disabled={state.preview}
           key={command |> commandToString}
           title={command |> commandToTitle}
           onClick={handleCommandClick(command, send)}>
           {command |> commandIcon}
         </button>
       );

  (
    switch (previewButtonPosition) {
    | PositionLeft => Array.append(previewOrEditButton, styleButtons)
    | PositionRight => Array.append(styleButtons, previewOrEditButton)
    }
  )
  |> React.array;
};

[@react.component]
let make =
    (
      ~textareaId=?,
      ~placeholder=?,
      ~updateDescriptionCB,
      ~value,
      ~label=?,
      ~profile,
      ~maxLength=1000,
      ~defaultView,
    ) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        description: value,
        preview:
          switch (defaultView) {
          | Preview => true
          | Edit => false
          },
        commandPair: {
          command: None,
          commandAt: None,
        },
      },
    );

  let (id, _setId) =
    React.useState(() =>
      switch (textareaId) {
      | Some(id) => id
      | None =>
        "markdown-editor-"
        ++ (Js.Date.now() |> Js.Float.toString)
        ++ "-"
        ++ (Js.Math.random_int(100000, 999999) |> string_of_int)
      }
    );

  let fileInputId = id ++ "-file-input";

  let (label, previewButtonPosition) =
    switch (label) {
    | Some(label) => (
        <label
          className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
          id>
          {label |> str}
        </label>,
        PositionLeft,
      )
    | None => (React.null, PositionRight)
    };

  <div>
    <div className="flex justify-between items-end bg-white pb-2">
      label
      <div className="flex markdown-button-group h-9">
        {buttons(state, send, previewButtonPosition)}
      </div>
    </div>
    {
      if (state.preview) {
        <MarkdownBlock
          markdown={state.description}
          className="pb-3 pt-2 leading-normal text-sm px-3 border border-transparent bg-gray-100 markdown-editor-preview"
          profile
        />;
      } else {
        let command =
          switch (state.commandPair.command) {
          | None => None
          | Some(c) => Some(c |> commandToString)
          };

        <div
          className="markdown-draft-editor__container text-sm border border-gray-400 rounded flex flex-col overflow-hidden">
          <DraftEditor
            ariaLabelledBy=id
            ?placeholder
            content={state.description}
            onChange={
              content =>
                updateDescription(value, content, send, updateDescriptionCB)
            }
            ?command
            commandAt=?{state.commandPair.commandAt}
          />
          <div
            className="bg-gray-100 flex-grow-0 border-t border-primary-200 border-dashed text-sm flex justify-between">
            <input className="hidden" type_="file" id=fileInputId />
            <label
              className="pl-3 py-1 flex-grow cursor-pointer"
              htmlFor=fileInputId>
              {"Attach files by clicking here and selecting a file." |> str}
            </label>
            <span
              className="px-3 py-1 hover:text-secondary-500 cursor-pointer">
              <FaIcon classes="fab fa-markdown" />
            </span>
          </div>
        </div>;
      }
    }
  </div>;
};

module Jsx2 = {
  let component = ReasonReact.statelessComponent("MarkDownEditor");

  let make =
      (
        ~placeholder,
        ~updateDescriptionCB,
        ~value,
        ~label,
        ~profile,
        ~maxLength,
        ~defaultView,
        children,
      ) =>
    ReasonReactCompat.wrapReactForReasonReact(
      make,
      makeProps(
        ~placeholder,
        ~updateDescriptionCB,
        ~value,
        ~label,
        ~profile,
        ~maxLength,
        ~defaultView,
        (),
      ),
      children,
    );
};
