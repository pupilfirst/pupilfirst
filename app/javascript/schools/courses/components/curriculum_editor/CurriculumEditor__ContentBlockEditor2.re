[@bs.config {jsx: 3}];

let str = React.string;

open CurriculumEditor__Types;

type state = {
  saving: option(string),
  contentBlock: ContentBlock.t,
};

let computeInitialState = contentBlock => {saving: None, contentBlock};

type action =
  | StartSaving(string)
  | FailSaving
  | UpdateContentBlock(ContentBlock.t);

let reducer = (state, action) =>
  switch (action) {
  | StartSaving(message) => {...state, saving: Some(message)}
  | FailSaving => {...state, saving: None}
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

let confirm = message => Webapi.Dom.(window |> Window.confirm(message));

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
  if (confirm("Are you sure you want to delete this block?")) {
    send(StartSaving("Deleting..."));
    let id = contentBlock |> ContentBlock.id;

    DeleteContentBlockMutation.make(~id, ())
    |> GraphqlQuery.sendQuery2
    |> Js.Promise.then_(result => {
         if (result##deleteContentBlock##success) {
           removeContentBlockCB(id);
         } else {
           send(FailSaving);
         };

         Js.Promise.resolve();
       })
    |> Js.Promise.catch(_error => {
         send(FailSaving);
         Js.Promise.resolve();
       })
    |> ignore;
  };

let onUndo = (originalContentBlock, setDirty, send, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  if (confirm("Are you sure you want to undo your changes to this block?")) {
    setDirty(false);
    send(UpdateContentBlock(originalContentBlock));
  };
};

let onSave = (contentBlock, removeContentBlockCB, send, _event) => ();

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
  | Markdown(_) => "Markdown Block" |> str
  | File(url, title, filename) =>
    <CurriculumEditor__FileBlockEditor url title filename updateTitleCB />
  | Image(_) => "Image Block" |> str
  };
};

[@react.component]
let make =
    (
      ~targetId,
      ~contentBlock,
      ~setDirtyCB,
      ~removeContentBlockCB=?,
      ~moveContentBlockUpCB=?,
      ~moveContentBlockDownCB=?,
      ~updateContentBlockCB,
    ) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, contentBlock, computeInitialState);

  <DisablingCover disabled={state.saving != None} message=?{state.saving}>
    <div className="flex">
      <div className="flex-grow">
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
             |> OptionUtils.map(cb => onSave(contentBlock, cb, send)),
         )}
      </div>
    </div>
  </DisablingCover>;
};
