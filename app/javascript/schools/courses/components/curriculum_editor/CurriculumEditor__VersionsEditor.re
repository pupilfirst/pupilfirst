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
    query($targetId: ID!, $versionOn: Date) {
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
  let response = ContentQuery.make(~targetId, ()) |> GraphqlQuery.sendQuery2;
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

let showDropdown = (versions, selectedVersion) => {
  let contents =
    versions
    |> Js.Array.filter(version => version != selectedVersion)
    |> Array.map(version =>
         <button
           id=version
           key=version
           className="whitespace-no-wrap px-3 py-2 cursor-pointer hover:bg-gray-100 hover:text-primary-500">
           {version |> DateTime.stingToFormatedTime(DateTime.OnlyDate) |> str}
         </button>
       );

  let selected =
    <button
      className="text-sm appearance-none bg-white border inline-flex items-center justify-between focus:outline-none font-semibold border-gray-400 hover:bg-gray-100 hover:shadow-lg">
      <span className="flex items-center py-2 px-3">
        <span className="truncate text-left">
          {selectedVersion
           |> DateTime.stingToFormatedTime(DateTime.OnlyDate)
           |> str}
        </span>
      </span>
      <span className="text-right px-3 py-2 border-l border-gray-400">
        <i className="fas fa-chevron-down text-sm" />
      </span>
    </button>;

  versions |> Array.length == 1
    ? <div
        className="text-sm appearance-none bg-white border focus:outline-none font-semibold rounded border-transparent cursor-auto">
        {selectedVersion
         |> DateTime.stingToFormatedTime(DateTime.OnlyDate)
         |> str}
      </div>
    : <Dropdown selected contents right=true />;
};

let showContentBlocks = (contentBlocks, versions) => {
  <div>
    <div>
      <label className="text-xs block text-gray-600 mb-1">
        {(versions |> Array.length > 1 ? "Versions" : "Version") |> str}
      </label>
      {showDropdown(versions, versions[0])}
    </div>
    <TargetContentView contentBlocks={contentBlocks |> Array.to_list} />
  </div>;
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
       : showContentBlocks(state.contentBlocks, state.versions)}
  </div>;
};
