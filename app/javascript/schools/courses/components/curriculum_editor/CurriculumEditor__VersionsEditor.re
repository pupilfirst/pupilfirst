[@bs.config {jsx: 3}];

let str = React.string;

open CurriculumEditor__Types;

type state =
  | Loading
  | Loaded(contentBlocks, selectedVersion, versions)
and contentBlocks = array(ContentBlock.t)
and selectedVersion = Version.t
and versions = array(Version.t);

type action =
  | LoadContent(array(ContentBlock.t), versions, selectedVersion)
  | SetLoading;

let reducer = (_state, action) =>
  switch (action) {
  | LoadContent(contentBlocks, versions, selectedVersion) =>
    Loaded(contentBlocks, selectedVersion, versions)
  | SetLoading => Loading
  };

module CreateTargetVersionMutation = [%graphql
  {|
   mutation($targetVersionId: ID!) {
    createTargetVersion(targetVersionId: $targetVersionId) {
       success
     }
   }
   |}
];

let loadContentBlocks = (targetId, send, version) => {
  let targetVersionId = version |> OptionUtils.map(Version.id);

  send(SetLoading);

  ContentBlock.Query.make(~targetId, ~targetVersionId?, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(result => {
       let contentBlocks =
         result##contentBlocks |> Js.Array.map(ContentBlock.makeFromJs);

       let versions = result##versions |> Version.makeArrayFromJs;

       let selectedVersion =
         switch (version) {
         | Some(v) => v
         | None => versions[0]
         };
       send(LoadContent(contentBlocks, versions, selectedVersion));

       Js.Promise.resolve();
     })
  |> ignore;
};

let createTargetVersion = (targetId, targetVersion, send) => {
  let targetVersionId = targetVersion |> Version.id;

  send(SetLoading);

  CreateTargetVersionMutation.make(~targetVersionId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(_result => {
       loadContentBlocks(targetId, send, None);
       Js.Promise.resolve();
     })
  |> ignore;
};

let versionText = version => {
  <div>
    <span className="font-semibold text-lg">
      {"#" ++ (version |> Version.number |> string_of_int) ++ " " |> str}
    </span>
    <span className="text-xs"> {version |> Version.versionAt |> str} </span>
  </div>;
};

let showDropdown = (versions, selectedVersion, loadContentBlocksCB) => {
  let contents =
    versions
    |> Js.Array.filter(version => version != selectedVersion)
    |> Array.map(version => {
         let id = version |> Version.id;

         <button
           id
           key=id
           title={"Select version " ++ id}
           onClick={_ => loadContentBlocksCB(Some(version))}
           className="whitespace-no-wrap px-3 py-2 cursor-pointer hover:bg-gray-100 hover:text-primary-500 w-full text-left">
           {versionText(version)}
         </button>;
       });

  let selected =
    <button
      title={"Select version " ++ (selectedVersion |> Version.id)}
      className="text-sm appearance-none bg-white border inline-flex items-center justify-between focus:outline-none border-gray-400 hover:bg-gray-100 hover:shadow-lg">
      <span className="py-2 px-3"> {versionText(selectedVersion)} </span>
      <span className="text-right px-3 py-2 border-l border-gray-400">
        <i className="fas fa-chevron-down text-sm" />
      </span>
    </button>;

  versions |> Array.length == 1
    ? <div
        className="text-sm appearance-none bg-white border focus:outline-none font-semibold rounded border-transparent cursor-auto">
        {selectedVersion |> Version.versionAt |> str}
      </div>
    : <Dropdown selected contents right=true />;
};

let showContentBlocks =
    (
      contentBlocks,
      versions,
      selectedVersion,
      loadContentBlocksCB,
      targetId,
      send,
    ) => {
  <div>
    <div className="flex items-end">
      <div>
        <label className="text-xs block text-gray-600 mb-1">
          {(versions |> Array.length > 1 ? "Versions" : "Version") |> str}
        </label>
        {showDropdown(versions, selectedVersion, loadContentBlocksCB)}
      </div>
      <div className="ml-2">
        <button
          className="text-sm appearance-none bg-white border inline-flex items-center justify-between focus:outline-none border-gray-400 hover:bg-gray-100 hover:shadow-lg px-2 py-3"
          onClick={_ => createTargetVersion(targetId, selectedVersion, send)}>
          {(
             selectedVersion |> Version.isLatestTargetVersion(versions)
               ? "Save this version" : "Restore this version"
           )
           |> str}
        </button>
      </div>
    </div>
    <TargetContentView contentBlocks />
  </div>;
};

[@react.component]
let make = (~targetId) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        Loading;
      },
    );

  let loadContentBlocksCB = loadContentBlocks(targetId, send);

  React.useEffect0(() => {
    loadContentBlocksCB(None);
    None;
  });

  <div className="max-w-3xl py-6 px-3 mx-auto">
    {switch (state) {
     | Loading =>
       SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.contents())
     | Loaded(contentBlocks, selectedVersion, versions) =>
       showContentBlocks(
         contentBlocks,
         versions,
         selectedVersion,
         loadContentBlocksCB,
         targetId,
         send,
       )
     }}
  </div>;
};
