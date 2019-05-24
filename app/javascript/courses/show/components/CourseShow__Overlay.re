[@bs.config {jsx: 3}];

open CourseShow__Types;

let str = React.string;

let loadTargetDetails = (target, setTargetDetails, ()) => {
  Js.Promise.(
    Fetch.fetch("/targets/" ++ (target |> Target.id) ++ "/details_v2")
    |> then_(Fetch.Response.json)
    |> then_(json =>
         setTargetDetails(_ => Some(json |> TargetDetails.decode)) |> resolve
       )
  )
  |> ignore;

  None;
};

type overlaySelection =
  | Learn
  | Discuss
  | Complete;

let overlaySelectionVisiblilityClasses =
    (inspectedSelection, currentSelection) =>
  inspectedSelection == currentSelection ? "" : "hidden";

let learnSection = (overlaySelection, targetDetails) =>
  <div
    className={overlaySelectionVisiblilityClasses(Learn, overlaySelection)}>
    {
      switch (targetDetails) {
      | Some(details) =>
        details
        |> TargetDetails.contentBlocks
        |> List.map(block => {
             let renderedBlock =
               switch (block |> ContentBlock.blockType) {
               | Markdown(markdown) => <MarkdownBlock markdown className="" />
               | File(url, title) =>
                 <a href=url> {"File: " ++ title |> str} </a>
               | Image(url, caption) => <img src=url alt=caption />
               | Embed(_url, embedCode) =>
                 <div dangerouslySetInnerHTML={"__html": embedCode} />
               };

             <div key={block |> ContentBlock.id}> renderedBlock </div>;
           })
        |> Array.of_list
        |> React.array
      | None => "Loading..." |> str
      }
    }
  </div>;

let selectionToString = overlaySelection =>
  switch (overlaySelection) {
  | Learn => "Learn"
  | Discuss => "Discuss"
  | Complete => "Complete"
  };

let overlaySelectionOptions = (target, overlaySelection, setOverlaySelection) =>
  <div className="border rounded-lg max-w-fc">
    {
      [Learn, Discuss, Complete]
      |> List.map(selection => {
           let classes =
             "inline-block p-4 cursor-pointer hover:bg-gray-200"
             ++ (overlaySelection == selection ? " bg-gray-300" : "");

           <span
             key={"select-" ++ (selection |> selectionToString)}
             className=classes
             onClick={_e => setOverlaySelection(_ => selection)}>
             {selection |> selectionToString |> str}
           </span>;
         })
      |> Array.of_list
      |> React.array
    }
  </div>;

let discussSection = (overlaySelection, _targetDetails) =>
  <div
    className={overlaySelectionVisiblilityClasses(Discuss, overlaySelection)}>
    {"Discussion section goes here" |> str}
  </div>;

let completeSection = (overlaySelection, _target) =>
  <div
    className={overlaySelectionVisiblilityClasses(Complete, overlaySelection)}>
    {"Submission form goes here" |> str}
  </div>;

[@react.component]
let make = (~target, ~targetStatus, ~closeOverlayCB) => {
  let (targetDetails, setTargetDetails) = React.useState(() => None);
  let (overlaySelection, setOverlaySelection) = React.useState(() => Learn);

  React.useEffect1(
    loadTargetDetails(target, setTargetDetails),
    [|target |> Target.id|],
  );

  <div className="absolute top-0 left-0 min-h-screen w-full bg-white">
    <button onClick={_e => closeOverlayCB()}> {"Close" |> str} </button>
    <h1> {target |> Target.title |> str} </h1>
    {overlaySelectionOptions(target, overlaySelection, setOverlaySelection)}
    {learnSection(overlaySelection, targetDetails)}
    {discussSection(overlaySelection, targetDetails)}
    {completeSection(overlaySelection, target)}
  </div>;
};