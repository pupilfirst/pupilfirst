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

let renderBlockClasses = block =>
  switch (block |> ContentBlock.blockType) {
  | Markdown(_) => "mt-4"
  | File(_) => "mt-4"
  | Image(_) => "mt-4"
  | Embed(_) => "flex justify-center mt-4"
  };

let markdownContentBlock = markdown => <MarkdownBlock markdown className="" />;

let fileContentBlock = (url, title, filename) =>
  <div className="mt-2 shadow-md border px-6 py-4 rounded-lg">
    <a className="flex justify-between items-center" href=url>
      <div className="flex items-center">
        <FaIcon classes="text-4xl text-red-600 fal fa-file-pdf" />
        <div className="pl-4 leading-tight">
          <div className="text-lg font-semibold"> {title |> str} </div>
          <div className="text-sm italic text-gray-600">
            {filename |> str}
          </div>
        </div>
      </div>
      <div> <FaIcon classes="text-2xl far fa-download" /> </div>
    </a>
  </div>;

let imageContentBlock = (url, caption) =>
  <div className="rounded-lg bg-gray-300">
    <img src=url alt=caption />
    <div className="px-4 py-2 text-sm italic"> {caption |> str} </div>
  </div>;

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
        |> ContentBlock.sort
        |> List.map(block => {
             let renderedBlock =
               switch (block |> ContentBlock.blockType) {
               | Markdown(markdown) => markdownContentBlock(markdown)
               | File(url, title, filename) =>
                 fileContentBlock(url, title, filename)
               | Image(url, caption) => imageContentBlock(url, caption)
               | Embed(url, embedCode) => embedContentBlock(url, embedCode)
               };

             <div
               className={renderBlockClasses(block)}
               key={block |> ContentBlock.id}>
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
  <div className="mt-4 flex justify-between max-w-3xl mx-auto">
    {
      [Learn, Discuss, Complete]
      |> List.map(selection => {
           let classes =
             "p-4 flex w-full justify-center rounded-lg border-2 border-b-0 font-semibold"
             ++ (
               overlaySelection == selection ?
                 " bg-white text-blue-600" :
                 " bg-gray-300 hover:bg-gray-200 cursor-pointer"
             );

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
    <div className="bg-gray-200 border-b-2">
      <div className="container mx-auto">
        {overlayStatus(closeOverlayCB, target, targetStatus)}
        {
          overlaySelectionOptions(
            target,
            overlaySelection,
            setOverlaySelection,
          )
        }
      </div>
    </div>
    <div className="container mx-auto p-4 max-w-3xl">
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