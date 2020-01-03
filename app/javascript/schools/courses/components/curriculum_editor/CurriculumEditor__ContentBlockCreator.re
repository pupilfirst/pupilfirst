[@bs.config {jsx: 3}];

let str = React.string;

type button =
  | MarkdownButton
  | FileButton
  | ImageButton
  | EmbedButton;

let buttonClasses = (visibility, staticMode) => {
  let classes = "add-content-block py-3 cursor-pointer";
  classes ++ (visibility || staticMode ? " add-content-block--open" : " ");
};

let createContentBlock =
    (
      formData,
      target,
      state,
      dispatch,
      blockType,
      sortIndex,
      createNewContentCB,
    ) =>
  Api.sendFormData(
    "/school/targets/" ++ (target |> Target.id) ++ "/content_block",
    formData,
    json => {
      Notification.success("Done!", "Content added successfully.");
      updateNewContentBlock(
        json,
        blockType,
        sortIndex,
        state,
        createNewContentCB,
      );
    },
    () => dispatch(UpdateSaving),
  );

let contentUploadContainer = (blockType, dispatch, state, editorId) =>
  <div
    className="content-block__content-placeholder flex flex-col justify-center text-center p-10">
    <div> {faIcons(blockType)} </div>
    <p className="text-xs text-gray-800 mt-1">
      {(
         switch (blockType) {
         | Markdown(_markdown) => ""
         | File(_url, _title, _filename) => "You can upload PDF, JPG, ZIP etc."
         | Image(_url, _caption) => "You can upload PNG, JPG, GIF files"
         | Embed(_url, _embedCode) => "Paste in a URL to embed"
         }
       )
       |> str}
    </p>
    {fileUploadButtonVisible(blockType)
       ? <div className="mt-2">
           <input
             id={"content-block-editor__file-input-" ++ editorId}
             type_="file"
             className="hidden"
             required=false
             multiple=false
             name="content_block[file]"
             onChange={event => handleFileUpload(dispatch, event, blockType)}
           />
           <label
             className="btn btn-primary"
             htmlFor={"content-block-editor__file-input-" ++ editorId}>
             <i className="fas fa-upload" />
             <span className="ml-2 truncate"> {state.fileName |> str} </span>
           </label>
         </div>
       : React.null}
  </div>;

let submitForm =
    (
      event,
      state,
      authenticityToken,
      blockType,
      dispatch,
      target,
      sortIndex,
      createNewContentCB,
    ) => {
  dispatch(BeginSaving);
  ReactEvent.Form.preventDefault(event);
  let element =
    ReactEvent.Form.target(event) |> DomUtils.EventTarget.unsafeToElement;

  let formData = DomUtils.FormData.create(element);

  createContentBlock(
    formData,
    target,
    state,
    dispatch,
    blockType,
    sortIndex,
    createNewContentCB,
  );
};

let button = (sortIndex, createNewContentBlockCB, button) => {
  let (faIcon, buttonText) =
    switch (button) {
    | MarkdownButton => ("fab fa-markdown", "Markdown")
    | FileButton => ("far fa-file-alt", "File")
    | ImageButton => ("far fa-image", "Image")
    | EmbedButton => ("fas fa-code", "Embed")
    };

  <div
    key=buttonText
    className="add-content-block__block-content-type-picker px-3 pt-4 pb-3 flex-1 text-center text-primary-200"
    onClick={event => {event |> ReactEvent.Mouse.preventDefault}}>
    <i className={faIcon ++ " text-2xl"} />
    <p className="font-semibold"> {buttonText |> str} </p>
  </div>;
};

[@react.component]
let make = (~sortIndex, ~staticMode, ~createNewContentBlockCB) => {
  let (visibility, setVisibility) = React.useState(() => false);
  <div className={buttonClasses(visibility, staticMode)}>
    {staticMode
       /* Spacer for add-content-block section */
       ? <div className="h-10" />
       : <div
           className="add-content-block__plus-button-container relative"
           onClick={_event => setVisibility(_ => !visibility)}>
           <div
             id={"add-block-" ++ (sortIndex |> string_of_int)}
             title="Add block"
             className="add-content-block__plus-button bg-gray-200 hover:bg-gray-300 relative rounded-lg border border-gray-500 w-10 h-10 flex justify-center items-center mx-auto z-20">
             <i
               className="fas fa-plus text-base add-content-block__plus-button-icon"
             />
           </div>
         </div>}
    <div
      className="add-content-block__block-content-type text-sm hidden shadow-lg mx-auto relative bg-primary-900 rounded-lg -mt-4 z-10"
      id={"content-type-picker-" ++ (sortIndex |> string_of_int)}>
      {[|MarkdownButton, ImageButton, EmbedButton, FileButton|]
       |> Array.map(button(sortIndex, createNewContentBlockCB))
       |> React.array}
    </div>
  </div>;
};
