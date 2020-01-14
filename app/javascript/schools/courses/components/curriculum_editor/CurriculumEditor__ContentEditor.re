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

[@react.component]
let make = (~targetId) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {loading: true, contentBlocks: [||], versions: [||]},
    );

  React.useEffect0(() => {
    loadContentBlocks(targetId, send);
    None;
  });

  <div className="max-w-3xl py-6 px-3 mx-auto">
    {state.loading
       ? SkeletonLoading.multiple(
           ~count=2,
           ~element=SkeletonLoading.contents(),
         )
       : <div> {"Show loaded content" |> str} </div>}
  </div>;
};
