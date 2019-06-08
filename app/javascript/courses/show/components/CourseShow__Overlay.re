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

let markdownContentBlock = markdown => <MarkdownBlock markdown className="" />;

let fileContentBlock = (url, title) =>
  <a href=url> {"File: " ++ title |> str} </a>;

let imageContentBlock = (url, caption) => <img src=url alt=caption />;

let embedContentBlock = (_url, embedCode) =>
  <div dangerouslySetInnerHTML={"__html": embedCode} />;

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
               | Markdown(markdown) => markdownContentBlock(markdown)
               | File(url, title) => fileContentBlock(url, title)
               | Image(url, caption) => imageContentBlock(url, caption)
               | Embed(url, embedCode) => embedContentBlock(url, embedCode)
               };

             <div className="mt-2" key={block |> ContentBlock.id}>
               renderedBlock
             </div>;
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
  <div className="border rounded-lg max-w-fc mt-4">
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

let discussSection = (overlaySelection, target, targetDetails) =>
  switch (targetDetails) {
  | Some(targetDetails) =>
    <div
      className={
        overlaySelectionVisiblilityClasses(Discuss, overlaySelection)
      }>
      {
        switch (targetDetails |> TargetDetails.communities) {
        | [] =>
          <div> {"Error: Discuss section must not be triggered!" |> str} </div>
        | communities => <CourseShow__Discuss target communities />
        }
      }
    </div>
  | None => <div> {"Loading..." |> str} </div>
  };

let completeSection =
    (overlaySelection, target, targetDetails, authenticityToken) =>
  switch (targetDetails) {
  | Some(targetDetails) =>
    <div
      className={
        overlaySelectionVisiblilityClasses(Complete, overlaySelection)
      }>
      {
        switch (targetDetails |> TargetDetails.quizQuestions) {
        | [] => <CourseShow__SubmissionForm target />
        | quizQuestions =>
          <CourseShow__Quiz target quizQuestions authenticityToken />
        }
      }
    </div>
  | None => <div> {"Loading..." |> str} </div>
  };

let overlayStatus = (closeOverlayCB, target, targetStatus) =>
  <div
    className="flex justify-between items-center py-4 px-6 bg-yellow-200 border-transparent rounded-b-lg">
    <div className="flex items-center">
      <button className="mr-4" onClick={_e => closeOverlayCB()}>
        <i className="fal fa-arrow-circle-left fa-2x" />
      </button>
      <h1 className="text-3xl"> {target |> Target.title |> str} </h1>
    </div>
    <div
      className="border-2 border-yellow-600 py-1 px-2 rounded-full text-yellow-600 font-bold">
      {targetStatus |> CourseShow__TargetStatus.statusToString |> str}
    </div>
  </div>;

[@react.component]
let make = (~target, ~targetStatus, ~closeOverlayCB, ~authenticityToken) => {
  let (targetDetails, setTargetDetails) = React.useState(() => None);
  let (overlaySelection, setOverlaySelection) = React.useState(() => Learn);

  React.useEffect1(
    loadTargetDetails(target, setTargetDetails),
    [|target |> Target.id|],
  );

  <div className="absolute top-0 left-0 min-h-screen w-full bg-white">
    <div className="container mx-auto px-4">
      {overlayStatus(closeOverlayCB, target, targetStatus)}
      {overlaySelectionOptions(target, overlaySelection, setOverlaySelection)}
      {learnSection(overlaySelection, targetDetails)}
      {discussSection(overlaySelection, target, targetDetails)}
      {
        completeSection(
          overlaySelection,
          target,
          targetDetails,
          authenticityToken,
        )
      }
    </div>
  </div>;
};