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

let updateDescription = (description, setDescription, updateDescriptionCB) => {
  setDescription(_ => description);
  updateDescriptionCB(description);
};

type previewButtonPosition =
  | PositionRight
  | PositionLeft;

let commandIcon = command =>
  switch (command) {
  | Bold => <i className="far fa-bold" />
  | Italic => <i className="far fa-italic" />
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

let handleCommandClick = (command, setCommandPair, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  let timeString = Js.Date.now() |> Js.Float.toString;
  setCommandPair(_ =>
    {command: Some(command), commandAt: Some(timeString)}
  );
};

let buttons =
    (description, setCommandPair, preview, setPreview, previewButtonPosition) => {
  let classes = "markdown-button-group__button hover:bg-primary-100 hover:text-primary-400 focus:outline-none focus:text-primary-600";

  let previewOrEditButton =
    (
      switch (description) {
      | "" => React.null
      | _someDescription =>
        <button
          key="preview-button"
          className=classes
          onClick=(
            event => {
              ReactEvent.Mouse.preventDefault(event);
              setPreview(_ => !preview);
            }
          )>
          <FaIcon classes={preview ? "fab fa-markdown" : "far fa-eye"} />
          <span className="ml-2">
            {(preview ? "Edit Markdown" : "Preview") |> str}
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
           disabled=preview
           key={command |> commandToString}
           title={command |> commandToTitle}
           onClick={handleCommandClick(command, setCommandPair)}>
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
  let (description, setDescription) = React.useState(() => value);
  let (preview, setPreview) =
    React.useState(() =>
      switch (defaultView) {
      | Preview => true
      | Edit => false
      }
    );
  let (id, _setId) =
    React.useState(() =>
      switch (textareaId) {
      | Some(id) => id
      | None =>
        "markdown-editor-"
        ++ (Js.Math.random_int(100000, 999999) |> string_of_int)
      }
    );

  let (commandPair, setCommandPair) =
    React.useState(() => {command: None, commandAt: None});

  let (label, previewButtonPosition) =
    switch (label) {
    | Some(label) => (
        <label
          className="inline-block tracking-wide text-gray-900 text-xs font-semibold"
          htmlFor=id>
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
        {
          buttons(
            description,
            setCommandPair,
            preview,
            setPreview,
            previewButtonPosition,
          )
        }
      </div>
    </div>
    {
      if (preview) {
        <MarkdownBlock
          markdown=description
          className="pb-3 pt-2 leading-normal text-sm px-3 border border-transparent bg-gray-100 markdown-editor-preview"
          profile
        />;
      } else {
        let command =
          switch (commandPair.command) {
          | None => None
          | Some(c) => Some(c |> commandToString)
          };

        <DraftEditor
          ariaLabelledBy=id
          ?placeholder
          content=description
          onChange={
            content =>
              updateDescription(content, setDescription, updateDescriptionCB)
          }
          ?command
          commandAt=?{commandPair.commandAt}
        />;
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