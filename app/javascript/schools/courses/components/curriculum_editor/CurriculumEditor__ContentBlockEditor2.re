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

let controlIcon = (icon, color, handler) => {
  let buttonClasses =
    switch (color) {
    | `Grey => "hover:bg-gray-200"
    | `Green => "bg-green-600 hover:bg-green-700 text-white rounded-br"
    };

  <button
    disabled={handler == None}
    className={"p-2 " ++ buttonClasses}
    onClick=?handler>
    <FaIcon classes={"fas fa-fw " ++ icon} />
  </button>;
};

let confirm = message => Webapi.Dom.(window |> Window.confirm(message));

let onMoveUp = Some(event => ());
let onMoveDown = Some(event => ());

let onDelete = (contentBlock, removeContentBlockCB, send, event) =>
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
    |> Js.Promise.catch(error => {
         send(FailSaving);
         Js.Promise.resolve();
       })
    |> ignore;
  };

let onUndo =
  Some(
    event =>
      if (confirm("Are you sure you want to undo your changes to this block?")) {
        ();
      },
  );

let onSave = Some(event => ());

[@react.component]
let make =
    (
      ~targetId,
      ~contentBlock,
      ~setDirty,
      ~removeContentBlockCB=?,
      ~updateContentBlockCB,
    ) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, contentBlock, computeInitialState);

  <DisablingCover disabled={state.saving != None} message=?{state.saving}>
    <div className="flex">
      <div className="flex-grow"> {"Inner Editor" |> str} </div>
      <div
        className="flex-shrink-0 mt-2 border-gray-300 bg-gray-100 border-t border-b border-r rounded-tr rounded-br flex flex-col text-xs">
        {controlIcon("fa-arrow-up", `Grey, onMoveUp)}
        {controlIcon("fa-arrow-down", `Grey, onMoveDown)}
        {controlIcon(
           "fa-trash-alt",
           `Grey,
           removeContentBlockCB
           |> OptionUtils.map(cb => onDelete(contentBlock, cb, send)),
         )}
        {controlIcon("fa-undo-alt", `Grey, onUndo)}
        {controlIcon("fa-check", `Green, onSave)}
      </div>
    </div>
  </DisablingCover>;
};
