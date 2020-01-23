[@bs.config {jsx: 3}];

let str = React.string;

open CurriculumEditor__Types;

type state = {
  loading: bool,
  contentBlocks: array(ContentBlock.t),
  versions: array(string),
};

type action =
  | LoadContent(array(ContentBlock.t), array(string))
  | AddContentBlock(ContentBlock.t);

let reducer = (state, action) =>
  switch (action) {
  | LoadContent(contentBlocks, versions) => {
      loading: false,
      contentBlocks,
      versions,
    }
  | AddContentBlock(newContentBlock) =>
    let newBlockSortIndex = newContentBlock |> ContentBlock.sortIndex;
    {
      ...state,
      contentBlocks:
        state.contentBlocks
        |> Array.map(contentBlock => {
             let sortIndex = contentBlock |> ContentBlock.sortIndex;

             if (sortIndex < newBlockSortIndex) {
               contentBlock;
             } else {
               contentBlock |> ContentBlock.incrementSortIndex;
             };
           })
        |> Array.append([|newContentBlock|]),
    };
  };

let loadContentBlocks = (targetId, send) => {
  let response =
    ContentBlock.Query.make(~targetId, ())
    |> GraphqlQuery.sendQuery(AuthenticityToken.fromHead(), ~notify=true);
  response
  |> Js.Promise.then_(result => {
       let contentBlocks =
         result##contentBlocks |> Js.Array.map(ContentBlock.makeFromJs);

       let versions =
         result##versions
         |> Array.map(version => version |> Json.Decode.string);

       send(LoadContent(contentBlocks, versions));

       Js.Promise.resolve();
     })
  |> ignore;
};

let addContentBlock = (send, contentBlock) =>
  send(AddContentBlock(contentBlock));

let editor = (target, state, send) => {
  let currentVersion =
    switch (state.versions) {
    | [||] => <span className="italic"> {"Not Versioned" |> str} </span>
    | versions =>
      let latestVersion =
        versions->Array.unsafe_get(0)
        |> DateFns.parseString
        |> DateFns.format("Do MMMM YYYY");

      latestVersion |> str;
    };

  let sortedContentBlocks = state.contentBlocks |> ContentBlock.sortArray;

  <div className="mt-2">
    <div className="flex justify-between items-end">
      {switch (target |> Target.visibility) {
       | Live =>
         <a
           href={"/targets/" ++ (target |> Target.id)}
           target="_blank"
           className="py-2 px-3 font-semibold rounded-lg text-sm focus:outline-none bg-primary-100 text-primary-500">
           <FaIcon classes="fas fa-external-link-alt" />
           <span className="ml-2"> {"View as Student" |> str} </span>
         </a>
       | Draft
       | Archived => React.null
       }}
      <div className="w-1/6">
        <label className="text-xs block text-gray-600 mb-1">
          {"Last Updated" |> str}
        </label>
        <span className="truncate text-left"> currentVersion </span>
      </div>
    </div>
    {sortedContentBlocks
     |> Array.map(contentBlock => {
          <div key={contentBlock |> ContentBlock.id}>
            <CurriculumEditor__ContentBlockCreator
              target
              aboveContentBlock=contentBlock
              addContentBlockCB={addContentBlock(send)}
            />
            <CurriculumEditor__ContentBlockEditor2
              targetId={target |> Target.id}
              setDirty={(_dirty, _targetId) => ()}
              contentBlock
              removeContentBlockCB={_contentBlockId => ()}
              updateContentBlockCB={_contentBlock => ()}
            />
          </div>
        })
     |> React.array}
    <CurriculumEditor__ContentBlockCreator
      target
      addContentBlockCB={addContentBlock(send)}
    />
  </div>;
};

[@react.component]
let make = (~target) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {loading: true, contentBlocks: [||], versions: [||]},
    );

  React.useEffect0(() => {
    loadContentBlocks(target |> Target.id, send);
    None;
  });

  <div className="max-w-3xl py-6 px-3 mx-auto">
    {state.loading
       ? SkeletonLoading.multiple(
           ~count=2,
           ~element=SkeletonLoading.contents(),
         )
       : editor(target, state, send)}
  </div>;
};
