[@bs.config {jsx: 3}];

exception InvalidBlockTypeForUpdate;

let str = React.string;

open CurriculumEditor__Types;

type state = {
  saving: option(string),
  contentBlock: ContentBlock.t,
};

let computeInitialState = contentBlock => {saving: None, contentBlock};

type action =
  | StartSaving(string)
  | FinishSaving
  | UpdateContentBlock(ContentBlock.t);

let reducer = (state, action) =>
  switch (action) {
  | StartSaving(message) => {...state, saving: Some(message)}
  | FinishSaving => {...state, saving: None}
  | UpdateContentBlock(contentBlock) => {...state, contentBlock}
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

module MoveContentBlockMutation = [%graphql
  {|
    mutation($id: ID!, $direction: MoveDirection!) {
      moveContentBlock(id: $id, direction: $direction) {
        success
      }
    }
  |}
];

module UpdateFileBlockMutation = [%graphql
  {|
    mutation($id: ID!, $title: String!) {
      updateFileBlock(id: $id, title: $title) {
        contentBlock {
          ...ContentBlock.Fragments.AllFields
        }
      }
    }
  |}
];

module UpdateMarkdownBlockMutation = [%graphql
  {|
    mutation($id: ID!, $markdown: String!) {
      updateMarkdownBlock(id: $id, markdown: $markdown) {
        contentBlock {
          ...ContentBlock.Fragments.AllFields
        }
      }
    }
  |}
];

module UpdateImageBlockMutation = [%graphql
  {|
    mutation($id: ID!, $caption: String!) {
      updateImageBlock(id: $id, caption: $caption) {
        contentBlock {
          ...ContentBlock.Fragments.AllFields
        }
      }
    }
  |}
];

let controlIcon = (~icon, ~title, ~color, ~handler) => {
  let buttonClasses =
    switch (color) {
    | `Grey => "hover:bg-gray-200"
    | `Green => "bg-green-600 hover:bg-green-700 text-white rounded-b"
    };

  <button
    title
    disabled={handler == None}
    className={"p-2 " ++ buttonClasses}
    onClick=?handler>
    <FaIcon classes={"fas fa-fw " ++ icon} />
  </button>;
};

let onMove = (contentBlock, cb, direction, _event) => {
  // We don't actually handle the response for this query.
  MoveContentBlockMutation.make(
    ~id=contentBlock |> ContentBlock.id,
    ~direction,
    (),
  )
  |> GraphqlQuery.sendQuery2
  |> ignore;

  cb(contentBlock);
};

let onDelete = (contentBlock, removeContentBlockCB, send, _event) =>
  WindowUtils.confirm("Are you sure you want to delete this block?", () => {
    send(StartSaving("Deleting..."));
    let id = contentBlock |> ContentBlock.id;

    DeleteContentBlockMutation.make(~id, ())
    |> GraphqlQuery.sendQuery2
    |> Js.Promise.then_(result => {
         if (result##deleteContentBlock##success) {
           removeContentBlockCB(id);
         } else {
           send(FinishSaving);
         };

         Js.Promise.resolve();
       })
    |> Js.Promise.catch(_error => {
         send(FinishSaving);
         Js.Promise.resolve();
       })
    |> ignore;
  });

let onUndo = (originalContentBlock, setDirty, send, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  WindowUtils.confirm(
    "Are you sure you want to undo your changes to this block?", () => {
    setDirty(false);
    send(UpdateContentBlock(originalContentBlock));
  });
};

let handleUpdateResult = (updateContentBlockCB, send, contentBlock) => {
  switch (contentBlock) {
  | Some(contentBlock) =>
    contentBlock |> ContentBlock.makeFromJs |> updateContentBlockCB;
    send(FinishSaving);
  | None => send(FinishSaving)
  };
  Js.Promise.resolve();
};

let updateContentBlockBlock =
    (mutation, contentBlockExtractor, updateContentBlockCB, send) => {
  send(StartSaving("Updating..."));

  mutation
  |> GraphqlQuery.sendQuery2
  |> Js.Promise.then_(result => {
       result
       |> contentBlockExtractor
       |> handleUpdateResult(updateContentBlockCB, send)
     })
  |> Js.Promise.catch(_error => {
       send(FinishSaving);
       Js.Promise.resolve();
     })
  |> ignore;
};

let onSave = (contentBlock, updateContentBlockCB, send, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  let id = contentBlock |> ContentBlock.id;

  switch (contentBlock |> ContentBlock.blockType) {
  | ContentBlock.File(_url, title, _filename) =>
    let mutation = UpdateFileBlockMutation.make(~id, ~title, ());
    let extractor = result => result##updateFileBlock##contentBlock;
    updateContentBlockBlock(mutation, extractor, updateContentBlockCB, send);
  | Markdown(markdown) =>
    let mutation = UpdateMarkdownBlockMutation.make(~id, ~markdown, ());
    let extractor = result => result##updateMarkdownBlock##contentBlock;
    updateContentBlockBlock(mutation, extractor, updateContentBlockCB, send);
  | Image(_url, caption) =>
    let mutation = UpdateImageBlockMutation.make(~id, ~caption, ());
    let extractor = result => result##updateImageBlock##contentBlock;
    updateContentBlockBlock(mutation, extractor, updateContentBlockCB, send);
  | Embed(_) => raise(InvalidBlockTypeForUpdate)
  };
};

let updateTitle = (originalContentBlock, setDirtyCB, send, newTitle) => {
  let newContentBlock =
    originalContentBlock |> ContentBlock.updateFile(newTitle);

  setDirtyCB(newContentBlock != originalContentBlock);
  send(UpdateContentBlock(newContentBlock));
};

let innerEditor = (originalContentBlock, contentBlock, setDirtyCB, send) => {
  let updateTitleCB = updateTitle(originalContentBlock, setDirtyCB, send);

  switch (contentBlock |> ContentBlock.blockType) {
  | ContentBlock.Embed(_) => "Embed Block" |> str
  | Markdown(markdown) =>
    <textarea className="w-full h-full border p-2">
      {markdown |> str}
    </textarea>
  | File(url, title, filename) =>
    <CurriculumEditor__FileBlockEditor url title filename updateTitleCB />
  | Image(_) => "Image Block" |> str
  };
};

[@react.component]
let make =
    (
      ~contentBlock,
      ~setDirtyCB,
      ~removeContentBlockCB=?,
      ~moveContentBlockUpCB=?,
      ~moveContentBlockDownCB=?,
      ~updateContentBlockCB=?,
    ) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, contentBlock, computeInitialState);

  <DisablingCover disabled={state.saving != None} message=?{state.saving}>
    <div className="flex items-start">
      <div className="flex-grow self-stretch">
        {innerEditor(contentBlock, state.contentBlock, setDirtyCB, send)}
      </div>
      <div
        className="ml-2 flex-shrink-0 border-transparent bg-gray-100 border rounded flex flex-col text-xs">
        {controlIcon(
           ~icon="fa-arrow-up",
           ~title="Move Up",
           ~color=`Grey,
           ~handler=
             moveContentBlockUpCB
             |> OptionUtils.map(cb => onMove(contentBlock, cb, `Up)),
         )}
        {controlIcon(
           ~icon="fa-arrow-down",
           ~title="Move Down",
           ~color=`Grey,
           ~handler=
             moveContentBlockDownCB
             |> OptionUtils.map(cb => onMove(contentBlock, cb, `Down)),
         )}
        {controlIcon(
           ~icon="fa-trash-alt",
           ~title="Delete",
           ~color=`Grey,
           ~handler=
             removeContentBlockCB
             |> OptionUtils.map(cb => onDelete(contentBlock, cb, send)),
         )}
        {controlIcon(
           ~icon="fa-undo-alt",
           ~title="Undo Changes",
           ~color=`Grey,
           ~handler=
             updateContentBlockCB
             |> OptionUtils.map(_cb => onUndo(contentBlock, setDirtyCB, send)),
         )}
        {controlIcon(
           ~icon="fa-check",
           ~title="Save Changes",
           ~color=`Green,
           ~handler=
             updateContentBlockCB
             |> OptionUtils.map(cb => onSave(state.contentBlock, cb, send)),
         )}
      </div>
    </div>
  </DisablingCover>;
};
