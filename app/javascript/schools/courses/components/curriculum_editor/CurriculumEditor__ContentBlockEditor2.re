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
  | FailSaving;

let reducer = (state, action) =>
  switch (action) {
  | StartSaving(message) => {...state, saving: Some(message)}
  | FailSaving => {...state, saving: None}
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
    | `Green => "bg-green-600 hover:bg-green-700 text-white rounded-br"
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

let onUndo =
  Some(
    _event =>
      if (confirm("Are you sure you want to undo your changes to this block?")) {
        ();
      },
  );

let onSave = Some(_event => ());

let innerEditor = contentBlock =>
  (
    switch (contentBlock |> ContentBlock.blockType) {
    | ContentBlock.Embed(_) => "Embed Block"
    | Markdown(_) => "Markdown Block"
    | File(_) => "File Block"
    | Image(_) => "Image Block"
    }
  )
  |> str;

[@react.component]
let make =
    (
      ~targetId,
      ~contentBlock,
      ~setDirty,
      ~removeContentBlockCB=?,
      ~moveContentBlockUpCB=?,
      ~moveContentBlockDownCB=?,
      ~updateContentBlockCB,
    ) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, contentBlock, computeInitialState);

  <DisablingCover disabled={state.saving != None} message=?{state.saving}>
    <div className="flex">
      <div className="flex-grow"> {innerEditor(contentBlock)} </div>
      <div
        className="flex-shrink-0 mt-2 border-gray-300 bg-gray-100 border-t border-b border-r rounded-tr rounded-br flex flex-col text-xs">
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
           ~handler=onUndo,
         )}
        {controlIcon(
           ~icon="fa-check",
           ~title="Save Changes",
           ~color=`Green,
           ~handler=onSave,
         )}
      </div>
    </div>
  </DisablingCover>;
};
