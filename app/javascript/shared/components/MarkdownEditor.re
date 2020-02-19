exception FormNotFound(string);

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
      ~commandAt: string=?,
      ~insertText: string=?
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

type attachmentError = option(string);

type attachment =
  | AttachingFile
  | ReadyToAttachFile(attachmentError);

type state = {
  preview: bool,
  commandPair,
  attachment,
  insertText: option(string),
};

type action =
  | TogglePreview
  | SetCommand(command)
  | SetAttaching
  | SetAttachmentError(attachmentError)
  | AddAttachment(string);

let reducer = (state, action) =>
  switch (action) {
  | AddAttachment(markdownEmbedCode) => {
      ...state,
      insertText: Some(markdownEmbedCode),
      attachment: ReadyToAttachFile(None),
    }
  | TogglePreview => {
      ...state,
      preview: !state.preview,
      commandPair: {
        command: None,
        commandAt: None,
      },
      insertText: None,
    }
  | SetCommand(command) =>
    let commandAt = Js.Date.now() |> Js.Float.toString;
    let commandPair = {command: Some(command), commandAt: Some(commandAt)};
    {...state, commandPair};
  | SetAttaching => {...state, attachment: AttachingFile}
  | SetAttachmentError(error) => {
      ...state,
      attachment: ReadyToAttachFile(error),
    }
  };

let addAttachment = (markdownEmbedCode, send) =>
  send(AddAttachment(markdownEmbedCode));

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

let buttons = (value, state, send, previewButtonPosition) => {
  let classes = "markdown-button-group__button hover:bg-primary-100 hover:text-primary-400 focus:outline-none focus:text-primary-600";

  let previewOrEditButton =
    (
      switch (value) {
      | "" => React.null
      | _someMarkdown =>
        <button
          key="preview-button"
          className=classes
          onClick={event => {
            ReactEvent.Mouse.preventDefault(event);
            send(TogglePreview);
          }}>
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

let handleUploadFileResponse = (send, json) => {
  let errors = json |> Json.Decode.(field("errors", array(string)));

  if (errors == [||]) {
    let markdownEmbedCode =
      json |> Json.Decode.(field("markdownEmbedCode", string));

    addAttachment("\n" ++ markdownEmbedCode ++ "\n", send);
  } else {
    send(
      SetAttachmentError(
        Some(
          "Failed to attach file! " ++ (errors |> Js.Array.joinWith(", ")),
        ),
      ),
    );
  };
};

let uploadFile = (send, formData) =>
  Api.sendFormData(
    "/markdown_attachments/", formData, handleUploadFileResponse(send), () =>
    ()
  );

let submitForm = (formId, send) => {
  let element = ReactDOMRe._getElementById(formId);
  switch (element) {
  | Some(element) => DomUtils.FormData.create(element) |> uploadFile(send)
  | None => raise(FormNotFound(formId))
  };
};

let attachFile = (send, fileFormId, event) =>
  switch (ReactEvent.Form.target(event)##files) {
  | [||] => ()
  | files =>
    let file = files[0];
    let maxFileSize = 5 * 1024 * 1024;

    let error =
      file##size > maxFileSize
        ? Some("The maximum file size is 5 MB. Please select another file.")
        : None;

    switch (error) {
    | Some(_) => send(SetAttachmentError(error))
    | None =>
      send(SetAttaching);
      submitForm(fileFormId, send);
    };
  };

let isEditorDisabled = attachment =>
  switch (attachment) {
  | AttachingFile => true
  | ReadyToAttachFile(_) => false
  };

[@react.component]
let make =
    (
      ~textareaId=?,
      ~placeholder=?,
      ~updateMarkdownCB,
      ~value,
      ~label=?,
      ~profile,
      ~maxLength=1000,
      ~defaultView,
      ~insertText=?,
    ) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        preview:
          switch (defaultView) {
          | Preview => true
          | Edit => false
          },
        commandPair: {
          command: None,
          commandAt: None,
        },
        attachment: ReadyToAttachFile(None),
        insertText,
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

  let fileFormId = id ++ "-file-form";
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
    <div
      className="flex justify-between items-end bg-white pb-2 sticky top-0 z-20">
      label
      <div className="flex markdown-button-group h-9 overflow-hidden">
        {buttons(value, state, send, previewButtonPosition)}
      </div>
    </div>
    {if (state.preview) {
       <MarkdownBlock
         markdown=value
         className="pb-3 pt-2 leading-relaxed px-3 border border-transparent bg-gray-100 markdown-editor-preview"
         profile
       />;
     } else {
       let command =
         switch (state.commandPair.command) {
         | None => None
         | Some(c) => Some(c |> commandToString)
         };

       <div
         className="markdown-draft-editor__container bg-white border border-gray-400 leading-relaxed rounded flex flex-col overflow-hidden">
         <DisablingCover
           disabled={isEditorDisabled(state.attachment)}
           message="Uploading..."
           containerClasses="flex flex-grow">
           <DraftEditor
             ariaLabelledBy=id
             ?placeholder
             content=value
             onChange=updateMarkdownCB
             ?command
             commandAt=?{state.commandPair.commandAt}
             insertText=?{state.insertText}
           />
         </DisablingCover>
         <div
           className="bg-gray-100 border-t border-gray-400 border-dashed flex justify-between items-center">
           <form
             className="flex items-center flex-wrap flex-1 text-sm font-semibold hover:bg-gray-200 hover:text-primary-500"
             id=fileFormId>
             <input
               name="authenticity_token"
               type_="hidden"
               value={AuthenticityToken.fromHead()}
             />
             <input
               className="hidden"
               type_="file"
               name="markdown_attachment[file]"
               id=fileInputId
               multiple=false
               onChange={attachFile(send, fileFormId)}
             />
             {switch (state.attachment) {
              | ReadyToAttachFile(error) =>
                <label
                  className="px-3 py-1 flex-grow cursor-pointer"
                  htmlFor=fileInputId>
                  {switch (error) {
                   | Some(error) =>
                     <span className="text-red-500">
                       <FaIcon classes="fas fa-exclamation-triangle mr-2" />
                       {error |> str}
                     </span>
                   | None =>
                     <span className="text-xs">
                       <FaIcon classes="far fa-file-image mr-2" />
                       {"Click here to attach a file." |> str}
                     </span>
                   }}
                </label>
              | AttachingFile =>
                <span className="pl-3 py-1 flex-grow cursor-wait">
                  <FaIcon classes="fas fa-spinner fa-pulse mr-2" />
                  {"Please wait for the file to upload..." |> str}
                </span>
              }}
           </form>
           <a
             href="/help/markdown_editor"
             target="_blank"
             className="flex items-center px-3 py-1 hover:bg-gray-200 hover:text-secondary-500 cursor-pointer">
             <FaIcon classes="fab fa-markdown text-sm" />
             <span className="text-xs ml-1 font-semibold hidden sm:inline">
               {"Need help?" |> str}
             </span>
           </a>
         </div>
       </div>;
     }}
  </div>;
};
