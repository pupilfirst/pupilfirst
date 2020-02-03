[@bs.config {jsx: 3}];

let str = React.string;

open CurriculumEditor__Types;

type state =
  | Loading
  | Loaded(contentBlocks, selectedVersion, versions)
and contentBlocks = array(ContentBlock.t)
and selectedVersion = Js.Date.t
and versions = array(Js.Date.t);

type action =
  | LoadContent(array(ContentBlock.t), versions, selectedVersion)
  | SetLoading;

let reducer = (_state, action) =>
  switch (action) {
  | LoadContent(contentBlocks, versions, selectedVersion) =>
    Loaded(contentBlocks, selectedVersion, versions)
  | SetLoading => Loading
  };

let loadContentBlocks = (targetId, send, version) => {
  let versionAt =
    version
    |> OptionUtils.map(Js.Date.toISOString)
    |> OptionUtils.map(Js.Json.string);

  send(SetLoading);

  ContentBlock.Query.make(~targetId, ~versionAt?, ())
  |> GraphqlQuery.sendQuery2
  |> Js.Promise.then_(result => {
       let contentBlocks =
         result##contentBlocks |> Js.Array.map(ContentBlock.makeFromJs);

       let versions =
         result##versions
         |> Array.map(v => v |> Json.Decode.string |> DateFns.parseString);

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

let showDropdown = (versions, selectedVersion, loadContentBlocksCB) => {
  let contents =
    versions
    |> Js.Array.filter(version => version != selectedVersion)
    |> Array.map(version => {
         let isoVersion = version |> Js.Date.toISOString;

         <button
           id=isoVersion
           key=isoVersion
           onClick={_ => loadContentBlocksCB(Some(version))}
           className="whitespace-no-wrap px-3 py-2 cursor-pointer hover:bg-gray-100 hover:text-primary-500">
           {version |> DateFns.distanceInWordsToNow(~addSuffix=true) |> str}
         </button>;
       });

  let selected =
    <button
      className="text-sm appearance-none bg-white border inline-flex items-center justify-between focus:outline-none font-semibold border-gray-400 hover:bg-gray-100 hover:shadow-lg">
      <span className="flex items-center py-2 px-3">
        <span className="truncate text-left">
          {selectedVersion
           |> DateFns.distanceInWordsToNow(~addSuffix=true)
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
        {selectedVersion |> DateFns.distanceInWordsToNow |> str}
      </div>
    : <Dropdown selected contents right=true />;
};

let showContentBlocks =
    (contentBlocks, versions, selectedVersion, loadContentBlocksCB) => {
  <div>
    <div>
      <label className="text-xs block text-gray-600 mb-1">
        {(versions |> Array.length > 1 ? "Versions" : "Version") |> str}
      </label>
      {showDropdown(versions, selectedVersion, loadContentBlocksCB)}
    </div>
    <TargetContentView contentBlocks={contentBlocks |> Array.to_list} />
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
       )
     }}
  </div>;
};
