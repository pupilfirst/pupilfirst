[@bs.config {jsx: 3}];
[%bs.raw {|require("./CourseShow__Overlay.css")|}];

open CourseShow__Types;

let str = React.string;

module ScrollLock = {
  open Webapi.Dom;

  let handleScrollLock = add => {
    let classes = add ? "overflow-hidden" : "";

    let body =
      document
      |> Document.getElementsByTagName("body")
      |> HtmlCollection.toArray;

    body[0]->Element.setClassName(classes);
  };
  let activate = () => handleScrollLock(true);
  let deActivate = () => handleScrollLock(false);
};

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

type methodOfCompletion =
  | Evaluated
  | TakeQuiz
  | LinkToComplete
  | MarkAsComplete;

type overlaySelection =
  | Learn
  | Discuss
  | Complete(methodOfCompletion);

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
      targetDetails
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
    }
  </div>;

let methodOfCompletionToString = methodOfCompletion =>
  switch (methodOfCompletion) {
  | Evaluated => "Complete"
  | TakeQuiz => "Take Quiz"
  | LinkToComplete => "Visit Link to Complete"
  | MarkAsComplete => "Mark as Complete"
  };

let selectionToString = overlaySelection =>
  switch (overlaySelection) {
  | Learn => "Learn"
  | Discuss => "Discuss"
  | Complete(methodOfCompletion) =>
    methodOfCompletionToString(methodOfCompletion)
  };

let computemethodOfCompletion = targetDetails => {
  let evaluated = targetDetails |> TargetDetails.evaluated;
  let hasQuiz =
    targetDetails |> TargetDetails.quizQuestions |> ListUtils.isNotEmpty;
  let hasLinkToComplete =
    switch (targetDetails |> TargetDetails.linkToComplete) {
    | Some(_) => true
    | None => false
    };
  switch (evaluated, hasQuiz, hasLinkToComplete) {
  | (true, _, _) => Evaluated
  | (false, true, _) => TakeQuiz
  | (false, false, true) => LinkToComplete
  | (_, _, _) => MarkAsComplete
  };
};

let selectableTabs = course =>
  course |> Course.enableDiscuss ? [Learn, Discuss] : [Learn];

let tabClasses = (selection, overlaySelection) =>
  "px-3 py-4 flex w-full justify-center text-sm -mx-px border border-gray-400 font-semibold"
  ++ (
    overlaySelection == selection ?
      " bg-white text-primary-500 border-b-0" :
      " bg-gray-100 hover:text-primary-400 hover:bg-gray-200 cursor-pointer"
  );

let tabButton = (selection, overlaySelection, setOverlaySelection) =>
  <span
    key={"select-" ++ (selection |> selectionToString)}
    className={tabClasses(selection, overlaySelection)}
    onClick={_e => setOverlaySelection(_ => selection)}>
    {selection |> selectionToString |> str}
  </span>;

let tabLink = (selection, overlaySelection) =>
  <a className={tabClasses(selection, overlaySelection)}>
    {selection |> selectionToString |> str}
  </a>;

let overlaySelectionOptions =
    (target, course, overlaySelection, setOverlaySelection, targetDetails) => {
  let methodOfCompletion = computemethodOfCompletion(targetDetails);
  <div className="flex justify-between max-w-3xl mx-auto -mb-px">
    {
      selectableTabs(course)
      |> List.map(selection =>
           tabButton(selection, overlaySelection, setOverlaySelection)
         )
      |> Array.of_list
      |> React.array
    }
    {
      switch (methodOfCompletion) {
      | Evaluated =>
        tabButton(Complete(Evaluated), overlaySelection, setOverlaySelection)
      | TakeQuiz =>
        tabButton(Complete(TakeQuiz), overlaySelection, setOverlaySelection)
      | _methodOfCompletion =>
        tabLink(Complete(_methodOfCompletion), overlaySelection)
      }
    }
  </div>;
};

let discussSection = (overlaySelection, target, targetDetails) =>
  <div
    className={overlaySelectionVisiblilityClasses(Discuss, overlaySelection)}>
    {
      switch (targetDetails |> TargetDetails.communities) {
      | [] =>
        <div> {"Error: Discuss section must not be triggered!" |> str} </div>
      | communities => <CourseShow__Discuss target communities />
      }
    }
  </div>;

let showQuizSection = (target, targetDetails, authenticityToken) => {
  let quizQuestions = targetDetails |> TargetDetails.quizQuestions;
  <CourseShow__Quiz target quizQuestions authenticityToken />;
};

let completeSection =
    (methodOfCompletion, target, targetDetails, authenticityToken) =>
  <div>
    {
      switch (methodOfCompletion) {
      | Evaluated => <CourseShow__SubmissionForm authenticityToken target />
      | TakeQuiz => showQuizSection(target, targetDetails, authenticityToken)
      | _ => React.null
      }
    }
  </div>;

let overlayStatus = (closeOverlayCB, target, targetStatus) =>
  <div
    className="course-overlay__header-title-card course-overlay__header-title-card--pending flex justify-between items-center p-6 mb-7 ">
    <div className="flex items-center">
      <button className="mr-4" onClick={_e => closeOverlayCB()}>
        <i className="fal fa-arrow-circle-left fa-2x" />
      </button>
      <h1 className="text-xl"> {target |> Target.title |> str} </h1>
    </div>
    <div
      className="curriculum__target-status curriculum__target-status--pending text-sm py-1 px-3">
      {targetStatus |> CourseShow__TargetStatus.statusToString |> str}
    </div>
  </div>;

[@react.component]
let make =
    (~target, ~course, ~targetStatus, ~closeOverlayCB, ~authenticityToken) => {
  let (targetDetails, setTargetDetails) = React.useState(() => None);
  let (overlaySelection, setOverlaySelection) = React.useState(() => Learn);

  React.useEffect1(
    loadTargetDetails(target, setTargetDetails),
    [|target |> Target.id|],
  );

  React.useEffect(() => {
    ScrollLock.activate();
    Some(() => ScrollLock.deActivate());
  });

  <div
    className="fixed z-20 top-0 left-0 w-full overflow-y-scroll bg-white h-screen">
    <div className="container bg-gray-100 border-b border-gray-400 px-3">
      <div className="course-overlay__header-container mx-auto">
        {overlayStatus(closeOverlayCB, target, targetStatus)}
        {
          switch (targetDetails) {
          | Some(targetDetails) =>
            overlaySelectionOptions(
              target,
              course,
              overlaySelection,
              setOverlaySelection,
              targetDetails,
            )
          | None => <div> {"Loading..." |> str} </div>
          }
        }
      </div>
    </div>
    <div className="container mx-auto mt-8 max-w-3xl px-3 md:px-0 pb-8">
      {
        switch (targetDetails) {
        | Some(targetDetails) =>
          switch (overlaySelection) {
          | Learn => learnSection(overlaySelection, targetDetails)

          | Discuss => discussSection(overlaySelection, target, targetDetails)

          | Complete(methodOfCompletion) =>
            completeSection(
              methodOfCompletion,
              target,
              targetDetails,
              authenticityToken,
            )
          }
        | None => <div> {"Loading..." |> str} </div>
        }
      }
    </div>
  </div>;
};
