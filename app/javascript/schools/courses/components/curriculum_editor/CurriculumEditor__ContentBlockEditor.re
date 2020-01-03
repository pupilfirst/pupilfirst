[@bs.config {jsx: 3}];

exception InvalidContentBlockTypeForUpdate;

open CurriculumEditor__Types;

let str = React.string;

type action =
  | BeginSaving
  | SetError(string)
  | FinishSaving
  | RevertChanges(ContentBlock.t)
  | UpdateFileTitle(string)
  | UpdateImageCaption(string)
  | UpdateMarkdown(string);

type networkState =
  | Pending
  | Saving
  | Errored(string);

type state = {
  contentBlock: ContentBlock.t,
  sortIndex: int,
  networkState,
};

let reducer = (state, action) =>
  switch (action) {
  | BeginSaving => {...state, networkState: Saving}
  | SetError(error) => {...state, networkState: Errored(error)}
  | FinishSaving => {...state, networkState: Pending}
  | RevertChanges(originalContentBlock) => {
      ...state,
      contentBlock: originalContentBlock,
    }
  | UpdateFileTitle(title) => {
      ...state,
      contentBlock: state.contentBlock |> ContentBlock.updateFileBlock(title),
    }
  | UpdateImageCaption(caption) => {
      ...state,
      contentBlock:
        state.contentBlock |> ContentBlock.updateImageBlock(caption),
    }
  | UpdateMarkdown(markdown) => {
      ...state,
      contentBlock:
        state.contentBlock |> ContentBlock.updateMarkdownBlock(markdown),
    }
  };

module DeleteContentBlockMutation = [%graphql
  {|
   mutation($id: ID!) {
    deleteContentBlock(id: $id) {
       success
       versions
     }
   }
   |}
];

module UpdateContentBlockMutation = [%graphql
  {|
   mutation($id: ID!, $text: String!, $blockType: String!) {
    updateContentBlock(id: $id, blockType: $blockType, text: $text ) {
       success
       id
       versions
   }
  }
  |}
];

let faIcons = (blockType: ContentBlock.blockType) =>
  switch (blockType) {
  | Markdown(_markdown) => React.null
  | File(_url, _title, _filename) =>
    <i className="fas fa-file text-6xl text-gray-500" />
  | Image(_url, _caption) =>
    <i className="fas fa-image text-6xl text-gray-500" />
  | Embed(_url, _embedCode) =>
    [|
      <i
        key="youtube-icon"
        className="fab fa-youtube text-6xl text-gray-500 px-2"
      />,
      <i
        key="slideshare-icon"
        className="fab fa-slideshare text-6xl text-gray-500 px-2"
      />,
      <i
        key="vimeo-icon"
        className="fab fa-vimeo text-6xl text-gray-500 px-2"
      />,
    |]
    |> React.array
  };

let fileUploadButtonVisible = (blockType: ContentBlock.blockType) =>
  switch (blockType) {
  | File(_url, _title, _filename) => true
  | Image(_url, _caption) => true
  | _ => false
  };

let uploadButtonText = blockType =>
  switch (blockType) {
  | ContentBlock.Markdown(_markdown) => ""
  | File(_url, _title, _filename) => "Select a file"
  | Image(_url, _caption) => "Select an image"
  | Embed(_url, _embedCode) => ""
  };

let handleFileUpload = (dispatch, event, blockType) => {
  switch (ReactEvent.Form.target(event)##files) {
  | [||] => dispatch(SetError("No file selected"))
  | files =>
    let file = files[0];
    let maxFileSize = 5 * 1024 * 1024;
    let error =
      file##size > maxFileSize
        ? Some("The maximum file size is 5 MB. Please select another file.")
        : None;
    switch (error) {
    | Some(errorMessage) =>
      dispatch(SetError(errorMessage));
      Notification.error("Upload Error", errorMessage);
    | None => dispatch(SetError("Failed to upload " ++ file##name))
    };
  };
};

let updateButtonVisible = blockType =>
  switch (blockType) {
  | ContentBlock.Embed(_url, _embedCode) => false
  | Markdown(_)
  | File(_)
  | Image(_) => true
  };

let editorButtonText = contentBlock =>
  switch (contentBlock |> ContentBlock.blockType) {
  | Markdown(_markdown) => "Update"
  | File(_url, _title, _filename) => "Update Title"
  | Image(_url, _caption) => "Update Caption"
  | Embed(_url, _embedCode) => "Update"
  };

let placeHolderText = (blockType: ContentBlock.blockType) =>
  switch (blockType) {
  | Markdown(_markdown) => ""
  | File(_url, _title, _filename) => "Type title for file"
  | Image(_url, _caption) => "Type caption for image (optional)"
  | Embed(_url, _embedCode) => "Paste in a URL to embed"
  };

let actionBarTextInputVisible = blockType =>
  switch (blockType) {
  | ContentBlock.Markdown(_markdown) => false
  | Embed(_url, _embedCode) => false
  | _ => true
  };

let handleDeleteContentBlock =
    (contentBlock, removeTargetContentCB, sortIndex) =>
  Webapi.Dom.window
  |> Webapi.Dom.Window.confirm("Are you sure you want to delete this block?")
    ? DeleteContentBlockMutation.make(~id=contentBlock |> ContentBlock.id, ())
      |> GraphqlQuery.sendQuery(AuthenticityToken.fromHead(), ~notify=true)
      |> Js.Promise.then_(response => {
           let versions =
             response##deleteContentBlock##versions
             |> Array.map(version => version |> Json.Decode.string);
           response##deleteContentBlock##success
             ? removeTargetContentCB(sortIndex, versions) : ();
           Js.Promise.resolve();
         })
      |> ignore
    : ();

let editableText = contentBlock =>
  switch (contentBlock |> ContentBlock.blockType) {
  | Markdown(markdown) => markdown
  | File(_url, title, _filename) => title
  | Image(_url, caption) => caption
  | Embed(_url, _embedCode) => raise(InvalidContentBlockTypeForUpdate)
  };

let updateContentBlock = (state, dispatch, sortIndex, updateContentBlockCB) => {
  let blockType =
    state.contentBlock
    |> ContentBlock.blockType
    |> ContentBlock.blockTypeToString;

  let id = state.contentBlock |> ContentBlock.id;

  UpdateContentBlockMutation.make(
    ~id,
    ~text=editableText(state.contentBlock),
    ~blockType,
    (),
  )
  |> GraphqlQuery.sendQuery(AuthenticityToken.fromHead(), ~notify=true)
  |> Js.Promise.then_(response => {
       let responseId = response##updateContentBlock##id;
       let versions =
         response##updateContentBlock##versions
         |> Array.map(version => version |> Json.Decode.string);
       dispatch(FinishSaving);
       updateContentBlockCB(state.contentBlock, id, versions);
       Js.Promise.resolve();
     })
  |> ignore;
};

let submitForm =
    (
      event,
      state,
      authenticityToken,
      blockType,
      dispatch,
      contentBlock,
      target,
      sortIndex,
      createNewContentCB,
      updateContentBlockCB,
    ) => {
  dispatch(BeginSaving);
  ReactEvent.Form.preventDefault(event);
  updateContentBlock(state, dispatch, sortIndex, updateContentBlockCB);
};

let content_sort_indices = (sortIndex, targetContentBlocks) => {
  let sort_indices = Js.Dict.empty();
  Js.Dict.set(
    sort_indices,
    "new",
    sortIndex |> string_of_int |> Js.Json.string,
  );
  targetContentBlocks
  |> List.iter(((index, _, cb, id)) =>
       switch (cb) {
       | Some(_cb) =>
         Js.Dict.set(
           sort_indices,
           id,
           index |> string_of_int |> Js.Json.string,
         )
       | None => ()
       }
     );
  Js.Json.stringify(Js.Json.object_(sort_indices));
};

[@react.component]
let make =
    (
      ~target,
      ~editorId,
      ~contentBlock,
      ~removeTargetContentCB,
      ~sortIndex,
      ~newContentBlockCB,
      ~blockCount,
      ~createNewContentCB,
      ~swapContentBlockCB,
      ~updateContentBlockCB,
      ~targetContentBlocks,
    ) => {
  let initialState = {contentBlock, sortIndex, networkState: Pending};

  let (state, dispatch) = React.useReducer(reducer, initialState);

  let updateMarkdownCB = string => {
    dispatch(UpdateMarkdown(string));
  };

  <DisablingCover message="Saving..." disabled={state.networkState == Saving}>
    <div>
      <div
        ariaLabel={
          (
            state.contentBlock
            |> ContentBlock.blockType
            |> ContentBlock.blockTypeToString
          )
          ++ " editor for "
          ++ editorId
        }
        className="relative border border-gray-400 rounded-lg">
        /* Content block controls */

          <div
            id={"content-block-controls-" ++ (sortIndex |> string_of_int)}
            className="flex absolute right-0 top-0 bg-white rounded-bl rounded-tr-lg overflow-hidden shadow z-30">
            {sortIndex != 1
               ? <button
                   title="Move up"
                   onClick={_event =>
                     swapContentBlockCB(sortIndex, sortIndex - 1)
                   }
                   className="px-3 py-2 text-gray-700 hover:text-primary-400 hover:bg-primary-100 focus:outline-none">
                   <i className="fas fa-arrow-up" />
                 </button>
               : React.null}
            {sortIndex != blockCount
               ? <button
                   title="Move down"
                   onClick={_event =>
                     swapContentBlockCB(sortIndex + 1, sortIndex)
                   }
                   className="px-3 py-2 text-gray-700 hover:text-primary-400 hover:bg-primary-100 focus:outline-none">
                   <i className="fas fa-arrow-down" />
                 </button>
               : React.null}
            <button
              title="Delete block"
              onClick={_event =>
                handleDeleteContentBlock(
                  contentBlock,
                  removeTargetContentCB,
                  sortIndex,
                )
              }
              className="px-3 py-2 text-gray-700 hover:text-red-500 hover:bg-red-100 focus:outline-none">
              <i className="fas fa-trash-alt" />
            </button>
          </div>
          // <input
          //   name="content_sort_indices"
          //   type_="hidden"
          //   value={content_sort_indices(sortIndex, targetContentBlocks)}
          // />
          // <input
          //   name="content_block[block_type]"
          //   type_="hidden"
          //   value={blockType |> ContentBlock.blockTypeAsString}
          // />
          // <input
          //   name="content_block[sort_index]"
          //   type_="hidden"
          //   value={state.sortIndex |> string_of_int}
          // />
          <div
            className="content-block__content text-base bg-gray-200 flex justify-center items-center rounded-t-lg">
            <div className="w-full">
              {switch (contentBlock |> ContentBlock.blockType) {
               | Markdown(markdown) =>
                 <MarkdownEditor
                   updateMarkdownCB
                   value=markdown
                   placeholder="You can use Markdown to format this text."
                   profile=Markdown.Permissive
                   maxLength=100000
                   defaultView=MarkdownEditor.Preview
                 />
               | Image(url, caption) =>
                 <div className="rounded-t-lg bg-white">
                   <img className="mx-auto" src=url alt=caption />
                   {switch (caption) {
                    | "" => React.null

                    | caption =>
                      <div className="px-4 py-2 text-sm italic text-center">
                        {caption |> str}
                      </div>
                    }}
                 </div>
               | Embed(_url, embedCode) =>
                 <div
                   className="content-block__embed rounded-lg overflow-hidden"
                   dangerouslySetInnerHTML={"__html": embedCode}
                 />
               | File(url, title, filename) =>
                 <a
                   className="flex justify-between items-center bg-white rounded-t-lg px-6 py-4 hover:bg-gray-100 hover:text-primary-500"
                   target="_blank"
                   href=url>
                   <div className="flex items-center">
                     <FaIcon
                       classes="text-4xl text-gray-800 far fa-file-alt"
                     />
                     <div className="pl-4 leading-tight">
                       <div className="text-lg font-semibold">
                         {title |> str}
                       </div>
                       <div className="text-sm italic text-gray-600">
                         {filename |> str}
                       </div>
                     </div>
                   </div>
                 </a>
               }}
            </div>
          </div>
          /* Content block action bar */
          <div className="flex border-t justify-end">
            {actionBarTextInputVisible(contentBlock |> ContentBlock.blockType)
               ? <div
                   className="flex-1 content-block__action-bar-input p-3 pr-0">
                   <input
                     className="appearance-none block w-full h-10 bg-white text-gray-800 border rounded py-3 px-3 focus:border-gray-400 leading-tight focus:outline-none focus:bg-white focus:border-gray"
                     id="captions"
                     name={
                       switch (contentBlock |> ContentBlock.blockType) {
                       | File(_url, _title, _filename) => "content_block[title]"
                       | Image(_url, _caption) => "content_block[caption]"
                       | Embed(_url, _embedCode) => "content_block[url]"
                       | Markdown(_markdown) => ""
                       }
                     }
                     onChange={event => {
                       let textValue = ReactEvent.Form.target(event)##value;
                       let action =
                         switch (contentBlock |> ContentBlock.blockType) {
                         | File(_url, _title, _filename) =>
                           UpdateFileTitle(textValue)
                         | Image(_url, _caption) =>
                           UpdateImageCaption(textValue)
                         | Embed(_url, _embedCode) =>
                           raise(InvalidContentBlockTypeForUpdate)
                         | Markdown(_markdown) =>
                           raise(InvalidContentBlockTypeForUpdate)
                         };

                       dispatch(action);
                     }}
                     type_="text"
                     value={state.contentBlock |> editableText}
                     placeholder={placeHolderText(
                       contentBlock |> ContentBlock.blockType,
                     )}
                   />
                 </div>
               : React.null}
            {updateButtonVisible(contentBlock |> ContentBlock.blockType)
               ? <div className="text-right py-3 pl-2 pr-3">
                   <button className="btn btn-large btn-success" disabled=true>
                     {editorButtonText(contentBlock) |> str}
                   </button>
                 </div>
               : React.null}
          </div>
        </div>
    </div>
  </DisablingCover>;
  /* Content block */
};
