[@bs.config {jsx: 3}];

[%bs.raw {|require("./CurriculumEditor__ContentBlockCreator.css")|}];

open CurriculumEditor__Types;

let str = React.string;

module CreateMarkdownCotentBlock = [%graphql
  {|
    mutation($targetId: ID!, $aboveContentBlockId: ID) {
      createMarkdownContentBlock(targetId: $targetId, aboveContentBlockId: $aboveContentBlockId) {
        success
      }
    }
  |}
];

type blockType =
  | Markdown
  | File
  | Image
  | Embed;

type state = {visible: bool};

type action =
  | ToggleVisibility;

let reducer = (state, action) =>
  switch (action) {
  | ToggleVisibility => {...state, visible: !state.visible}
  };

let computeInitialState = isAboveTarget => {
  {visible: !isAboveTarget};
};

let containerClasses = (visible, isAboveTarget) => {
  let classes = "content-block-creator py-3";
  classes ++ (visible || !isAboveTarget ? " content-block-creator--open" : "");
};

let createMarkdownContentBlock =
    (target, aboveContentBlock, send, addContentBlockCB) => {
  let aboveContentBlockId =
    aboveContentBlock |> OptionUtils.map(ContentBlock.id);
  let targetId = target |> Target.id;
  CreateMarkdownCotentBlock.make(~targetId, ~aboveContentBlockId?, ())
  |> GraphqlQuery.sendQuery2
  |> Js.Promise.then_(result => {
       Js.log("done!");
       Js.Promise.resolve();
     })
  |> ignore;
};

let onClick =
    (target, aboveContentBlock, send, addContentBlockCB, blockType, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  switch (blockType) {
  | Markdown =>
    createMarkdownContentBlock(
      target,
      aboveContentBlock,
      send,
      addContentBlockCB,
    )
  | File => ()
  | Image => ()
  | Embed => ()
  };
};

let button = (target, aboveContentBlock, send, addContentBlockCB, blockType) => {
  let (faIcon, buttonText) =
    switch (blockType) {
    | Markdown => ("fab fa-markdown", "Markdown")
    | File => ("far fa-file-alt", "File")
    | Image => ("far fa-image", "Image")
    | Embed => ("fas fa-code", "Embed")
    };

  <div
    key=buttonText
    className="content-block-creator__block-content-type-picker px-3 pt-4 pb-3 flex-1 text-center text-primary-200"
    onClick={onClick(
      target,
      aboveContentBlock,
      send,
      addContentBlockCB,
      blockType,
    )}>
    <i className={faIcon ++ " text-2xl"} />
    <p className="font-semibold"> {buttonText |> str} </p>
  </div>;
};

[@react.component]
let make = (~target, ~aboveContentBlock=?, ~addContentBlockCB) => {
  let isAboveContentBlock = aboveContentBlock != None;

  let (state, send) =
    React.useReducerWithMapState(
      reducer,
      isAboveContentBlock,
      computeInitialState,
    );

  <div className={containerClasses(state.visible, isAboveContentBlock)}>
    {switch (aboveContentBlock) {
     | Some(contentBlock) =>
       <div
         className="content-block-creator__plus-button-container relative cursor-pointer"
         onClick={_event => send(ToggleVisibility)}>
         <div
           id={"add-block-above-" ++ (contentBlock |> ContentBlock.id)}
           title="Add block"
           className="content-block-creator__plus-button bg-gray-200 hover:bg-gray-300 relative rounded-lg border border-gray-500 w-10 h-10 flex justify-center items-center mx-auto z-20">
           <i
             className="fas fa-plus text-base content-block-creator__plus-button-icon"
           />
         </div>
       </div>
     | None => <div className="h-10" />
     }}
    <div
      className="content-block-creator__block-content-type text-sm hidden shadow-lg mx-auto relative bg-primary-900 rounded-lg -mt-4 z-10">
      {[|Markdown, Image, Embed, File|]
       |> Array.map(
            button(target, aboveContentBlock, send, addContentBlockCB),
          )
       |> React.array}
    </div>
  </div>;
};
