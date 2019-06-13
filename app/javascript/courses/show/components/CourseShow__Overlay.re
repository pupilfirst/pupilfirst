[@bs.config {jsx: 3}];
[%bs.raw {|require("./CourseShow__Overlay.css")|}];

open CourseShow__Types;
module TargetStatus = CourseShow__TargetStatus;

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

type completionType =
  | Evaluated
  | TakeQuiz
  | LinkToComplete
  | MarkAsComplete;

type overlaySelection =
  | Learn
  | Discuss
  | Complete(completionType);

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

let learnSection = targetDetails =>
  <div>
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

let completionTypeToString = (completionType, targetStatus) =>
  switch (targetStatus |> TargetStatus.status, completionType) {
  | (Pending, Evaluated) => "Complete"
  | (Pending, TakeQuiz) => "Take Quiz"
  | (Pending, LinkToComplete) => "Visit Link to Complete"
  | (Pending, MarkAsComplete) => "Mark as Complete"
  | (Submitted | Passed | Failed, Evaluated | TakeQuiz) => "Submissions and Review"
  | (Submitted | Passed | Failed, LinkToComplete | MarkAsComplete) => "Completed"
  /* Locked is an imposible state */
  | (Locked(_), Evaluated | TakeQuiz | LinkToComplete | MarkAsComplete) => "Locked"
  };

let selectionToString = (targetStatus, overlaySelection) =>
  switch (overlaySelection) {
  | Learn => "Learn"
  | Discuss => "Discuss"
  | Complete(completionType) =>
    completionTypeToString(completionType, targetStatus)
  };

let computeCompletionType = targetDetails => {
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

let tabButton =
    (selection, overlaySelection, setOverlaySelection, targetStatus) =>
  <span
    key={"select-" ++ (selection |> selectionToString(targetStatus))}
    className={tabClasses(selection, overlaySelection)}
    onClick={_e => setOverlaySelection(_ => selection)}>
    {selection |> selectionToString(targetStatus) |> str}
  </span>;

let tabLink = (selection, overlaySelection, pending) =>
  <a
    href="#auto-verify-target"
    className={tabClasses(selection, overlaySelection)}>
    {selection |> selectionToString(pending) |> str}
  </a>;

let overlaySelectionOptions =
    (
      target,
      course,
      overlaySelection,
      setOverlaySelection,
      targetDetails,
      targetStatus,
    ) => {
  let completionType = computeCompletionType(targetDetails);

  <div className="flex justify-between max-w-3xl mx-auto -mb-px">
    {
      selectableTabs(course)
      |> List.map(selection =>
           tabButton(
             selection,
             overlaySelection,
             setOverlaySelection,
             targetStatus,
           )
         )
      |> Array.of_list
      |> React.array
    }
    {
      switch (targetStatus |> TargetStatus.status, completionType) {
      | (Pending | Submitted | Passed | Failed, Evaluated) =>
        tabButton(
          Complete(Evaluated),
          overlaySelection,
          setOverlaySelection,
          targetStatus,
        )
      | (Pending | Submitted | Passed | Failed, TakeQuiz) =>
        tabButton(
          Complete(TakeQuiz),
          overlaySelection,
          setOverlaySelection,
          targetStatus,
        )
      | (Pending | Submitted | Passed | Failed, _completionTypes) =>
        tabLink(Complete(_completionTypes), overlaySelection, targetStatus)

      | (Locked(_), _) => React.null
      }
    }
  </div>;
};

let discussSection = (target, targetDetails) => {
  let communities = targetDetails |> TargetDetails.communities;
  <CourseShow__Discuss target communities />;
};

let showQuizSection = (target, targetDetails, authenticityToken) => {
  let quizQuestions = targetDetails |> TargetDetails.quizQuestions;
  <CourseShow__Quiz target quizQuestions authenticityToken />;
};

let completeSection =
    (completionType, target, targetDetails, authenticityToken, targetStatus) =>
  <div>
    {
      switch (targetStatus |> TargetStatus.status, completionType) {
      | (Pending, Evaluated) =>
        <CourseShow__SubmissionForm authenticityToken target />
      | (Pending, TakeQuiz) =>
        showQuizSection(target, targetDetails, authenticityToken)

      | (Submitted | Passed | Failed, Evaluated | TakeQuiz) =>
        <CourseShow__SubmissionsAndFeedbacks targetDetails />
      | (Submitted | Passed | Failed, LinkToComplete | MarkAsComplete)
      | (Pending, LinkToComplete | MarkAsComplete)
      | (Locked(_), Evaluated | TakeQuiz | MarkAsComplete | LinkToComplete) => React.null
      }
    }
  </div>;

let overlayStatus = (closeOverlayCB, target, targetStatus) =>
  <div
    className="course-overlay__header-title-card course-overlay__header-title-card--pending flex justify-between items-center px-3 py-5 md:p-6 mb-5 md:mb-7 ">
    <button
      className="xl:absolute pr-4 xl:-ml-20 focus:outline-none"
      onClick={_e => closeOverlayCB()}>
      <i className="fal fa-arrow-circle-left text-3xl text-gray-800" />
      <span className="block text-gray-800 font-semibold text-xs uppercase">
        {"Back" |> str}
      </span>
    </button>
    <div className="w-full flex items-center justify-between relative">
      <h1 className="text-base leading-snug mr-3 md:text-xl">
        {target |> Target.title |> str}
      </h1>
      <div
        className="curriculum__target-status curriculum__target-status--pending text-xs md:text-sm py-1 px-2 md:px-4">
        {targetStatus |> CourseShow__TargetStatus.statusToString |> str}
      </div>
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
    className="fixed z-20 top-0 left-0 w-full h-full overflow-y-scroll bg-white">
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
              targetStatus,
            )
          | None =>
            <div className="text-center text-sm font-semibold">
              {"Loading..." |> str}
            </div>
          }
        }
      </div>
    </div>
    <div
      className="container mx-auto mt-6 md:mt-8 max-w-3xl px-3 md:px-0 pb-8">
      {
        switch (targetDetails) {
        | Some(targetDetails) =>
          <div>
            {
              switch (overlaySelection) {
              | Learn => learnSection(targetDetails)
              | Discuss => discussSection(target, targetDetails)
              | Complete(completionType) =>
                completeSection(
                  completionType,
                  target,
                  targetDetails,
                  authenticityToken,
                  targetStatus,
                )
              }
            }
            {
              switch (computeCompletionType(targetDetails)) {
              | LinkToComplete
              | MarkAsComplete =>
                <CourseShow__AutoVerify
                  target
                  targetDetails
                  authenticityToken
                  targetStatus
                />
              | _ => React.null
              }
            }
          </div>
        | None => <div> {"Loading..." |> str} </div>
        }
      }
    </div>
  </div>;
};