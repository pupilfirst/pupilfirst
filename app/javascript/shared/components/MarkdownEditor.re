[@bs.config {jsx: 3}];

exception FormNotFound(string);
exception UnexpectedResponse(int);

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
  markdown: string,
  preview: bool,
  commandPair,
  attachment,
  insertText: option(string),
};

type action =
  | UpdateMarkdown(string)
  | TogglePreview
  | SetCommand(command)
  | SetAttaching
  | SetAttachmentError(attachmentError)
  | AddAttachment(string);

let reducer = (state, action) =>
  switch (action) {
  | UpdateMarkdown(markdown) => {...state, markdown}
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

let updateMarkdown = (markdown, send, updateMarkdownCB) => {
  send(UpdateMarkdown(markdown));
  updateMarkdownCB(markdown);
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
      switch (state.markdown) {
      | "" => React.null
      | _someMarkdown =>
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

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let attachmentEmbedGap = oldMarkdown =>
  if (oldMarkdown == "") {
    "";
  } else if (oldMarkdown |> Js.String.substr(~from=-1) == "\n") {
    "\n";
  } else {
    "\n\n";
  };

let uploadFile = (send, oldMarkdown, updateMarkdownCB, formData) =>
  Js.Promise.(
    Fetch.fetchWithInit(
      "/markdown_attachments/",
      Fetch.RequestInit.make(
        ~method_=Post,
        ~body=Fetch.BodyInit.makeWithFormData(formData),
        ~credentials=Fetch.SameOrigin,
        (),
      ),
    )
    |> then_(response =>
         if (Fetch.Response.ok(response)) {
           response |> Fetch.Response.json;
         } else {
           Js.Promise.reject(
             UnexpectedResponse(response |> Fetch.Response.status),
           );
         }
       )
    |> then_(json => {
         let errors = json |> Json.Decode.(field("errors", array(string)));

         if (errors == [||]) {
           let markdownEmbedCode =
             json |> Json.Decode.(field("markdownEmbedCode", string));

           addAttachment("\n" ++ markdownEmbedCode ++ "\n", send);
         } else {
           send(
             SetAttachmentError(
               Some(
                 "Failed to attach file! "
                 ++ (errors |> Js.Array.joinWith(", ")),
               ),
             ),
           );
         };
         resolve();
       })
    |> catch(error =>
         (
           switch (error |> handleApiError) {
           | Some(code) =>
             Notification.error(
               "Error " ++ (code |> string_of_int),
               "Please reload the page and try again.",
             )
           | None =>
             Notification.error(
               "Something went wrong!",
               "Our team has been notified of this error. Please reload the page and try again.",
             )
           }
         )
         |> resolve
       )
    |> ignore
  );

let submitForm = (formId, send, oldMarkdown, updateMarkdownCB) => {
  let element = ReactDOMRe._getElementById(formId);
  switch (element) {
  | Some(element) =>
    DomUtils.FormData.create(element)
    |> uploadFile(send, oldMarkdown, updateMarkdownCB)
  | None => raise(FormNotFound(formId))
  };
};

let attachFile = (send, oldMarkdown, updateMarkdownCB, fileFormId, event) =>
  switch (ReactEvent.Form.target(event)##files) {
  | [||] => ()
  | files =>
    let file = files[0];
    let maxFileSize = 5 * 1024 * 1024;

    let error =
      file##size > maxFileSize ?
        Some("The maximum file size is 5 MB. Please select another file.") :
        None;

    switch (error) {
    | Some(_) => send(SetAttachmentError(error))
    | None =>
      send(SetAttaching);
      submitForm(fileFormId, send, oldMarkdown, updateMarkdownCB);
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
    ) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        markdown: value,
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
        insertText: None,
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
      className="flex justify-between items-end bg-white rounded-t-lg pb-2 sticky top-0 z-20">
      label
      <div className="flex markdown-button-group h-9 overflow-hidden">
        {buttons(state, send, previewButtonPosition)}
      </div>
    </div>
    {
      if (state.preview) {
        <MarkdownBlock
          markdown={state.markdown}
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
          <DisablingCover
            disabled={isEditorDisabled(state.attachment)}
            message="Uploading..."
            containerClasses="flex flex-grow">
            <DraftEditor
              ariaLabelledBy=id
              ?placeholder
              content={state.markdown}
              onChange={
                newMarkdownContent =>
                  value == newMarkdownContent ?
                    () :
                    updateMarkdown(newMarkdownContent, send, updateMarkdownCB)
              }
              ?command
              commandAt=?{state.commandPair.commandAt}
              insertText=?{state.insertText}
            />
          </DisablingCover>
          <div
            className="bg-gray-100 flex-grow-0 border-t border-primary-200 border-dashed text-sm flex justify-between">
            <form className="flex items-center flex-wrap" id=fileFormId>
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
                onChange={
                  attachFile(
                    send,
                    state.markdown,
                    updateMarkdownCB,
                    fileFormId,
                  )
                }
              />
              {
                switch (state.attachment) {
                | ReadyToAttachFile(error) =>
                  <label
                    className="pl-3 py-1 flex-grow cursor-pointer"
                    htmlFor=fileInputId>
                    {
                      switch (error) {
                      | Some(error) =>
                        <span className="text-red-500">
                          <FaIcon classes="fas fa-exclamation-triangle mr-2" />
                          {error |> str}
                        </span>
                      | None =>
                        <span>
                          <FaIcon classes="far fa-file-image mr-2" />
                          {"Click here to attach a file." |> str}
                        </span>
                      }
                    }
                  </label>
                | AttachingFile =>
                  <span className="pl-3 py-1 flex-grow cursor-wait">
                    <FaIcon classes="fas fa-spinner fa-pulse mr-2" />
                    {"Please wait for the file to upload..." |> str}
                  </span>
                }
              }
            </form>
            <a
              href="/help/markdown"
              target="_blank"
              className="px-3 py-1 hover:text-secondary-500 cursor-pointer">
              <FaIcon classes="fab fa-markdown" />
              <span className="text-xs ml-1 font-semibold hidden sm:inline">
                {"Need help?" |> str}
              </span>
            </a>
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
        ~updateMarkdownCB,
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
        ~updateMarkdownCB,
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