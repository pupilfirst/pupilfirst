[@bs.config {jsx: 3}];

let str = React.string;

open CurriculumEditor__Types;

type state = {
  loading: bool,
  contentBlocks: array(ContentBlock.t),
  versions: array(string),
};

type action =
  | LoadContent(array(ContentBlock.t), array(string));

let reducer = (state, action) =>
  switch (action) {
  | LoadContent(contentBlocks, versions) => {
      loading: false,
      contentBlocks,
      versions,
    }
  };

module ContentQuery = [%graphql
  {|
    query($targetId: ID!, $versionOn: Date ) {
      contentBlocks(targetId: $targetId, versionOn: $versionOn) {
        id
        blockType
        sortIndex
        content {
          ... on ImageBlock {
            caption
            url
            filename
          }
          ... on FileBlock {
            title
            url
            filename
          }
          ... on MarkdownBlock {
            markdown
          }
          ... on EmbedBlock {
            url
            embedCode
          }
        }
      }
      versions(targetId: $targetId)
  }
|}
];

let loadContentBlocks = (targetId, send) => {
  let response =
    ContentQuery.make(~targetId, ())
    |> GraphqlQuery.sendQuery(AuthenticityToken.fromHead(), ~notify=true);
  response
  |> Js.Promise.then_(result => {
       let contentBlocks =
         result##contentBlocks
         |> Js.Array.map(rawContentBlock => {
              let id = rawContentBlock##id;
              let sortIndex = rawContentBlock##sortIndex;
              let blockType =
                switch (rawContentBlock##content) {
                | `MarkdownBlock(content) =>
                  ContentBlock.Markdown(content##markdown)
                | `FileBlock(content) =>
                  File(content##url, content##title, content##filename)
                | `ImageBlock(content) =>
                  Image(content##url, content##caption)
                | `EmbedBlock(content) =>
                  Embed(content##url, content##embedCode)
                };
              ContentBlock.make(id, blockType, sortIndex);
            });

       let versions =
         result##versions
         |> Array.map(version => version |> Json.Decode.string);

       send(LoadContent(contentBlocks, versions));

       Js.Promise.resolve();
     })
  |> ignore;
};

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
          {"Version" |> str}
        </label>
        <span className="truncate text-left"> currentVersion </span>
      </div>
    </div>
    {sortedContentBlocks
     |> Array.map(contentBlock => {
          <CurriculumEditor__ContentBlockEditor2
            key={contentBlock |> ContentBlock.id}
            targetId={target |> Target.id}
            contentBlock
            removeContentBlockCB={_contentBlockId => ()}
            updateContentBlockCB={_contentBlock => ()}
          />
        })
     |> React.array}
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
    <h2> {target |> Target.title |> str} </h2>
    {state.loading
       ? SkeletonLoading.multiple(
           ~count=2,
           ~element=SkeletonLoading.contents(),
         )
       : editor(target, state, send)}
  </div>;
};
