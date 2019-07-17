[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

exception UnexpectedResponse(int);

let str = React.string;

type action =
  | UpdateContentBlockPropertyText(string)
  | UpdateSaving
  | DoneUpdating
  | UpdateMarkdown(string)
  | UpdateFileName(string);

type state = {
  contentBlockPropertyText: string,
  contentBlock: option(ContentBlock.t),
  sortIndex: int,
  savingContentBlock: bool,
  markDownContent: string,
  fileName: string,
  embedUrl: string,
  formDirty: bool,
};

let reducer = (state, action) =>
  switch (action) {
  | UpdateContentBlockPropertyText(text) => {
      ...state,
      contentBlockPropertyText: text,
      formDirty:
        switch (state.contentBlock) {
        | Some(_contentBlock) => true
        | None => true
        },
    }
  | UpdateSaving => {...state, savingContentBlock: !state.savingContentBlock}
  | UpdateMarkdown(text) => {
      ...state,
      markDownContent: text,
      formDirty: true,
    }
  | UpdateFileName(fileName) => {...state, fileName, formDirty: true}
  | DoneUpdating => {...state, formDirty: false, savingContentBlock: false}
  };

module DeleteContentBlockMutation = [%graphql
  {|
   mutation($id: ID!) {
    deleteContentBlock(id: $id) {
       success
     }
   }
   |}
];

module UpdateContentBlockMutation = [%graphql
  {|
   mutation($id: ID!, $text: String!, $blockType: String!) {
    updateContentBlock(id: $id, blockType: $blockType, text: $text ) {
       success
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

let contentUploadContainer = (blockType, dispatch, state) =>
  <div
    className="content-block__content-placeholder flex flex-col justify-center text-center p-10">
    <div> {faIcons(blockType)} </div>
    <p className="text-xs text-gray-800 mt-1">
      {
        (
          switch (blockType) {
          | Markdown(_markdown) => ""
          | File(_url, _title, _filename) => "You can upload PDF, JPG, ZIP etc."
          | Image(_url, _caption) => "You can upload PNG, JPG, GIF files"
          | Embed(_url, _embedCode) => "Paste in a URL to embed"
          }
        )
        |> str
      }
    </p>
    {
      fileUploadButtonVisible(blockType) ?
        <div className="mt-2">
          <input
            id="content-block-editor__file-input"
            type_="file"
            className="hidden"
            required=false
            multiple=false
            name="content_block[file]"
            onChange={
              event =>
                dispatch(
                  UpdateFileName(
                    ReactEvent.Form.target(event)##files[0]##name,
                  ),
                )
            }
          />
          <label
            className="btn btn-primary"
            htmlFor="content-block-editor__file-input">
            <i className="fas fa-upload" />
            <span className="ml-2 truncate"> {state.fileName |> str} </span>
          </label>
        </div> :
        React.null
    }
  </div>;

let saveDisabled = state => !state.formDirty || state.savingContentBlock;

let scrollMethod = () => {
  let scrollContainer =
    Webapi.Dom.(
      document |> Document.getElementById("target-editor-scroll-container")
    );

  switch (scrollContainer) {
  | Some(element) => MarkdownEditor.TextArea.ScrollElement(element)
  | None => MarkdownEditor.TextArea.ScrollWindow
  };
};

let updateButtonVisible = (contentBlock, blockType: ContentBlock.blockType) =>
  switch (contentBlock) {
  | Some(_contentBlock) =>
    switch (blockType) {
    | Embed(_url, _embedCode) => false
    | _ => true
    }
  | None => true
  };

let editorButtonText = contentBlock =>
  switch (contentBlock) {
  | Some(contentBlock) =>
    switch (contentBlock |> ContentBlock.blockType) {
    | Markdown(_markdown) => "Update"
    | File(_url, _title, _filename) => "Update Title"
    | Image(_url, _caption) => "Update Caption"
    | Embed(_url, _embedCode) => "Update"
    }
  | None => "Save"
  };

let placeHolderText = (blockType: ContentBlock.blockType) =>
  switch (blockType) {
  | Markdown(_markdown) => ""
  | File(_url, _title, _filename) => "Type title for file"
  | Image(_url, _caption) => "Type caption for image (optional)"
  | Embed(_url, _embedCode) => "Paste in a URL to embed"
  };

let actionBarTextInputVisible =
    (blockType: ContentBlock.blockType, contentBlock) =>
  switch (blockType) {
  | Markdown(_markdown) => false
  | Embed(_url, _embedCode) =>
    switch (contentBlock) {
    | Some(_contentBlock) => false
    | None => true
    }
  | _ => true
  };

let handleDeleteContentBlock =
    (contentBlock, authenticityToken, removeTargetContentCB, sortIndex) =>
  Webapi.Dom.window
  |> Webapi.Dom.Window.confirm(
       "Are you sure you want to delete this content?. You cannot undo this.",
     ) ?
    switch (contentBlock) {
    | Some(contentBlock) =>
      let id = ContentBlock.id(contentBlock);
      DeleteContentBlockMutation.make(~id, ())
      |> GraphqlQuery.sendQuery(authenticityToken, ~notify=true)
      |> Js.Promise.then_(response => {
           response##deleteContentBlock##success ?
             removeTargetContentCB(sortIndex) : ();
           Js.Promise.resolve();
         })
      |> ignore;
    | None => removeTargetContentCB(sortIndex)
    } :
    ();
let decodeContent =
    (blockType: ContentBlock.blockType, fileUrl, state, content) =>
  Json.Decode.(
    switch (blockType) {
    | Markdown(_markdown) =>
      ContentBlock.makeMarkdownBlock(state.markDownContent)
    | File(_url, _title, _filename) =>
      ContentBlock.makeFileBlock(
        fileUrl,
        content |> field("title", string),
        state.fileName,
      )
    | Image(_url, _caption) =>
      ContentBlock.makeImageBlock(
        fileUrl,
        content |> field("caption", string),
      )
    | Embed(_url, _embedCode) =>
      ContentBlock.makeEmbedBlock(
        content |> field("url", string),
        content |> field("embed_code", string),
      )
    }
  );

let updateNewContentBlock =
    (
      json,
      blockType: ContentBlock.blockType,
      target,
      sortIndex,
      state,
      createNewContentCB,
    ) => {
  open Json.Decode;
  let id = json |> field("id", string);
  let fileUrl =
    switch (blockType) {
    | File(_url, _title, _filename) => json |> field("fileUrl", string)
    | Image(_url, _caption) => json |> field("fileUrl", string)
    | _ => ""
    };
  let contentBlockType =
    json |> field("content", decodeContent(blockType, fileUrl, state));
  let newContentBlock =
    ContentBlock.make(id, contentBlockType, target |> Target.id, sortIndex);
  createNewContentCB(newContentBlock);
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
  SchoolAdmin__Api.sendFormData(
    "/school/targets/" ++ (target |> Target.id) ++ "/content_block",
    formData,
    json => {
      Notification.success("Done!", "Content added successfully.");
      updateNewContentBlock(
        json,
        blockType,
        target,
        sortIndex,
        state,
        createNewContentCB,
      );
      dispatch(UpdateSaving);
    },
    () => dispatch(UpdateSaving),
  );
let updateContentBlock =
    (
      contentBlock,
      state,
      authenticityToken,
      dispatch,
      sortIndex,
      updateContentBlockCB,
    ) => {
  let id = contentBlock |> ContentBlock.id;
  let text =
    switch (contentBlock |> ContentBlock.blockType) {
    | Markdown(_markdown) => state.markDownContent
    | File(_url, _title, _filename) => state.contentBlockPropertyText
    | Image(_url, _caption) => state.contentBlockPropertyText
    | Embed(_url, _embedCode) => ""
    };
  let blockType =
    contentBlock |> ContentBlock.blockType |> ContentBlock.blockTypeAsString;
  UpdateContentBlockMutation.make(~id, ~text, ~blockType, ())
  |> GraphqlQuery.sendQuery(authenticityToken, ~notify=true)
  |> Js.Promise.then_(_response => {
       dispatch(DoneUpdating);
       Js.Promise.resolve();
     })
  |> ignore;
  let updatedContentBlockType =
    switch (contentBlock |> ContentBlock.blockType) {
    | Markdown(_markdown) =>
      ContentBlock.makeMarkdownBlock(state.markDownContent)
    | File(url, _title, filename) =>
      ContentBlock.makeFileBlock(
        url,
        state.contentBlockPropertyText,
        filename,
      )
    | Image(url, _caption) =>
      ContentBlock.makeImageBlock(url, state.contentBlockPropertyText)
    | Embed(_url, _embedCode) => contentBlock |> ContentBlock.blockType
    };
  let updatedContentBlock =
    ContentBlock.make(
      id,
      updatedContentBlockType,
      contentBlock |> ContentBlock.targetId,
      sortIndex,
    );
  updateContentBlockCB(updatedContentBlock);
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
  dispatch(UpdateSaving);
  ReactEvent.Form.preventDefault(event);
  switch (contentBlock) {
  | Some(contentBlock) =>
    updateContentBlock(
      contentBlock,
      state,
      authenticityToken,
      dispatch,
      sortIndex,
      updateContentBlockCB,
    )
  | None =>
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
};

[@react.component]
let make =
    (
      ~target,
      ~editorId,
      ~contentBlock,
      ~blockType: ContentBlock.blockType,
      ~removeTargetContentCB,
      ~sortIndex,
      ~newContentBlockCB,
      ~blockCount,
      ~createNewContentCB,
      ~swapContentBlockCB,
      ~updateContentBlockCB,
      ~authenticityToken,
    ) => {
  let initialState = {
    contentBlockPropertyText:
      switch (blockType) {
      | Markdown(_markdown) => ""
      | File(_url, title, _filename) => title
      | Image(_url, caption) => caption
      | Embed(_url, embedCode) => embedCode
      },
    contentBlock,
    sortIndex,
    savingContentBlock: false,
    markDownContent:
      switch (blockType) {
      | Markdown(markdown) => markdown
      | _ => ""
      },
    fileName:
      switch (blockType) {
      | Markdown(_markdown) => ""
      | File(_url, _title, _filename) => "Select a file"
      | Image(_url, _caption) => "Select an image"
      | Embed(_url, _embedCode) => ""
      },
    embedUrl: "",
    formDirty: false,
  };

  let (state, dispatch) = React.useReducer(reducer, initialState);

  let updateDescriptionCB = string => dispatch(UpdateMarkdown(string));

  <DisablingCover message="Saving..." disabled={state.savingContentBlock}>
    <div>
      <CurriculumEditor__ContentTypePicker
        key={sortIndex |> string_of_int}
        sortIndex
        newContentBlockCB
        staticMode=false
      />
      /* Content block */
      <div
        className="relative border border-gray-400 rounded-lg overflow-hidden">
        /* Content block controls */

          <div
            id={"content-block-controls-" ++ (sortIndex |> string_of_int)}
            className="flex absolute right-0 top-0 bg-white rounded-bl overflow-hidden shadow z-20">
            {
              sortIndex != 1 ?
                <button
                  title="Move up"
                  onClick={
                    _event => swapContentBlockCB(sortIndex, sortIndex - 1)
                  }
                  className="px-3 py-2 text-gray-700 hover:text-primary-400 hover:bg-primary-100 focus:outline-none">
                  <i className="fas fa-arrow-up" />
                </button> :
                React.null
            }
            {
              sortIndex != blockCount ?
                <button
                  title="Move down"
                  onClick={
                    _event => swapContentBlockCB(sortIndex + 1, sortIndex)
                  }
                  className="px-3 py-2 text-gray-700 hover:text-primary-400 hover:bg-primary-100 focus:outline-none">
                  <i className="fas fa-arrow-down" />
                </button> :
                React.null
            }
            <button
              title="Delete block"
              onClick={
                _event =>
                  handleDeleteContentBlock(
                    contentBlock,
                    authenticityToken,
                    removeTargetContentCB,
                    sortIndex,
                  )
              }
              className="px-3 py-2 text-gray-700 hover:text-red-500 hover:bg-red-100 focus:outline-none">
              <i className="fas fa-trash-alt" />
            </button>
          </div>
          <form
            id={"content-block-form-" ++ (sortIndex |> string_of_int)}
            key={"content-block-form-" ++ editorId}
            onSubmit={
              event =>
                submitForm(
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
                )
            }>
            <input
              name="authenticity_token"
              type_="hidden"
              value=authenticityToken
            />
            <input
              name="content_block[block_type]"
              type_="hidden"
              value={blockType |> ContentBlock.blockTypeAsString}
            />
            <input
              name="content_block[sort_index]"
              type_="hidden"
              value={state.sortIndex |> string_of_int}
            />
            <div
              className="content-block__content bg-gray-200 flex justify-center items-center">
              {
                switch (contentBlock) {
                | Some(contentBlock) =>
                  <div className="w-full">
                    {
                      switch (contentBlock |> ContentBlock.blockType) {
                      | Markdown(markdown) =>
                        <MarkdownEditor
                          updateDescriptionCB
                          value=markdown
                          placeholder="You can use Markdown to format this text."
                          profile=Markdown.Permissive
                          maxLength=100000
                          scrollMethod={scrollMethod()}
                          defaultView=MarkdownEditor.Preview
                        />
                      | Image(url, caption) =>
                        <div className="rounded-lg bg-white">
                          <img className="mx-auto" src=url alt=caption />
                          <div
                            className="px-4 py-2 text-sm italic text-center">
                            {caption |> str}
                          </div>
                        </div>
                      | Embed(_url, embedCode) =>
                        <div
                          className="content-block__embed"
                          dangerouslySetInnerHTML={"__html": embedCode}
                        />
                      | File(url, title, filename) =>
                        <a
                          className="flex justify-between items-center bg-white px-6 py-4 hover:bg-gray-100 hover:text-primary-500"
                          target="_blank"
                          href=url>
                          <div className="flex items-center">
                            <FaIcon
                              classes="text-4xl text-gray-800 fal fa-file-alt"
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
                      }
                    }
                  </div>
                | None =>
                  switch (blockType) {
                  | Markdown(_markdown) =>
                    <div className="w-full">
                      <MarkdownEditor
                        updateDescriptionCB
                        value=""
                        placeholder="You can use Markdown to format this text."
                        profile=Markdown.Permissive
                        maxLength=100000
                        scrollMethod={scrollMethod()}
                        defaultView=MarkdownEditor.Edit
                      />
                    </div>
                  | _ => contentUploadContainer(blockType, dispatch, state)
                  }
                }
              }
              {
                switch (blockType) {
                | Markdown(_markdown) =>
                  <input
                    type_="hidden"
                    name="content_block[markdown]"
                    value={state.markDownContent}
                  />
                | _ => React.null
                }
              }
            </div>
            /* Content block action bar */
            <div className="flex p-3 border-t justify-end">
              {
                actionBarTextInputVisible(blockType, contentBlock) ?
                  <div className="flex-1 content-block__action-bar-input">
                    <input
                      className="appearance-none block w-full h-10 bg-white text-gray-800 border border-transparent rounded py-3 px-3 focus:border-gray-400 leading-tight focus:outline-none focus:bg-white focus:border-gray"
                      id="captions"
                      name={
                        switch (blockType) {
                        | File(_url, _title, _filename) => "content_block[title]"
                        | Image(_url, _caption) => "content_block[caption]"
                        | Embed(_url, _embedCode) => "content_block[url]"
                        | Markdown(_markdown) => ""
                        }
                      }
                      onChange={
                        event =>
                          dispatch(
                            UpdateContentBlockPropertyText(
                              ReactEvent.Form.target(event)##value,
                            ),
                          )
                      }
                      type_="text"
                      value={state.contentBlockPropertyText}
                      placeholder={placeHolderText(blockType)}
                    />
                  </div> :
                  React.null
              }
              {
                updateButtonVisible(contentBlock, blockType) ?
                  <div className="ml-2 text-right">
                    <button
                      className="btn btn-large btn-success"
                      disabled={saveDisabled(state)}>
                      {editorButtonText(contentBlock) |> str}
                    </button>
                  </div> :
                  React.null
              }
            </div>
          </form>
        </div>
    </div>
  </DisablingCover>;
};
