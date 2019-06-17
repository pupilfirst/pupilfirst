[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

let str = React.string;

type action =
  | UpdateContentBlockPropertyText(string)
  | CreateNewContentBlock;

type state = {
  contentBlockPropertyText: string,
  contentBlock: option(ContentBlock.t),
};

let reducer = (state, action) =>
  switch (action) {
  | UpdateContentBlockPropertyText(text) => {
      ...state,
      contentBlockPropertyText: text,
    }
  | CreateNewContentBlock => state
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

[@react.component]
let make =
    (
      ~target,
      ~contentBlock,
      ~blockType: ContentBlock.blockType,
      ~removeTargetContentCB,
      ~sortIndex=?,
      ~authenticityToken,
    ) => {
  let handleInitialState = {
    contentBlockPropertyText:
      switch (blockType) {
      | Markdown(_markdown) => ""
      | File(_url, title, _filename) => title
      | Image(_url, caption) => caption
      | Embed(_url, embedCode) => embedCode
      },
    contentBlock,
  };

  let (state, dispatch) = React.useReducer(reducer, handleInitialState);
  let updateDescriptionCB = string => Js.log(string);
  let editorButtonText =
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
  let placeHolderText =
    switch (blockType) {
    | Markdown(_markdown) => ""
    | File(_url, _title, _filename) => "Type title for file"
    | Image(_url, _caption) => "Type caption for image (optional)"
    | Embed(_url, _embedCode) => "URL for the embed content"
    };
  let actionBarTextInputVisible =
    switch (blockType) {
    | Markdown(_markdown) => false
    | Embed(_url, _embedCode) => false
    | _ => true
    };
  let updateButtonVisible =
    switch (blockType) {
    | Embed(_url, _embedCode) => false
    | _ => true
    };

  let handleDeleteContentBlock = contentBlock =>
    switch (contentBlock) {
    | Some(contentBlock) =>
      let id = ContentBlock.id(contentBlock);
      DeleteContentBlockMutation.make(~id, ())
      |> GraphqlQuery.sendQuery(authenticityToken)
      |> Js.Promise.then_(response => {
           response##deleteContentBlock##success ?
             removeTargetContentCB(id) : ();
           Js.Promise.resolve();
         })
      |> ignore;
    | None => ()
    };

  <div>
    <CurriculumEditor__ContentTypePicker staticMode=false />
    <div
      className="[ content-block ] relative border border-gray-400 rounded-lg overflow-hidden">
      <div
        className="[ content-block__controls ] flex absolute right-0 top-0 bg-white rounded-bl shadow z-20">
        /* Notice the classes [ classname ] do not exists in the CSS file. When scanning HTML,
           it helps to quickly differentiate who does what */

          <button
            title="Move up"
            className="px-3 py-2 text-gray-700 hover:text-primary-400 hover:bg-primary-100 focus:outline-none">
            <i className="fas fa-arrow-up" />
          </button>
          <button
            title="Move down"
            className="px-3 py-2 text-gray-700 hover:text-primary-400 hover:bg-primary-100 focus:outline-none">
            <i className="fas fa-arrow-down" />
          </button>
          <button
            title="Delete block"
            onClick={_event => handleDeleteContentBlock(contentBlock)}
            className="px-3 py-2 text-gray-700 hover:text-red-500 hover:bg-red-100 focus:outline-none">
            <i className="fas fa-trash-alt" />
          </button>
        </div>
      <div
        className="content-block__content bg-gray-200 flex justify-center items-center">
        {
          switch (contentBlock) {
          | Some(contentBlock) =>
            <div className="w-full">
              {
                switch (contentBlock |> ContentBlock.blockType) {
                | Markdown(markdown) =>
                  <MarkDownEditor
                    updateDescriptionCB
                    value=markdown
                    placeholder="You can use Markdown to format this text."
                  />
                | Image(url, caption) =>
                  <div className="rounded-lg bg-gray-300">
                    <img src=url alt=caption />
                    <div className="px-4 py-2 text-sm italic">
                      {caption |> str}
                    </div>
                  </div>
                | Embed(_url, embedCode) =>
                  <div
                    className="content-block__embed"
                    dangerouslySetInnerHTML={"__html": embedCode}
                  />
                | File(url, title, filename) =>
                  <div
                    className="bg-white shadow-md border px-6 py-4 rounded-lg">
                    <a className="flex justify-between items-center" href=url>
                      <div className="flex items-center">
                        <FaIcon
                          classes="text-4xl text-red-600 fal fa-file-pdf"
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
                  </div>
                }
              }
            </div>
          | None =>
            <div
              className="content-block__content-placeholder text-center p-10">
              <i className="fas fa-image text-6xl text-gray-500" />
              <p className="text-xs text-gray-700 mt-1">
                {"You can upload PNG, JPG, GIF files" |> str}
              </p>
              <div className="flex justify-center relative mt-2">
                <input
                  id="content-block-image-input"
                  type_="file"
                  className="input-file__input cursor-pointer px-4"
                />
                <label
                  className="btn btn-primary flex absolute"
                  htmlFor="content-block-image-input">
                  <i className="fas fa-upload" />
                  <span className="ml-2 truncate">
                    {"Select an image" |> str}
                  </span>
                </label>
              </div>
            </div>
          }
        }
      </div>
      <div
        className="[ content-block__action-bar ] flex p-3 border-t justify-end">
        {
          actionBarTextInputVisible ?
            <div className="flex-1 content-block__action-bar-input">
              <input
                className="appearance-none block w-full h-10 bg-white text-gray-800 border border-transparent rounded py-3 px-3 focus:border-gray-400 leading-tight focus:outline-none focus:bg-white focus:border-gray"
                id="captions"
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
                placeholder=placeHolderText
              />
            </div> :
            React.null
        }
        {
          updateButtonVisible ?
            <div className="ml-2 text-right">
              <button className="btn btn-large btn-success disabled">
                {editorButtonText |> str}
              </button>
            </div> :
            React.null
        }
      </div>
    </div>
  </div>;
};