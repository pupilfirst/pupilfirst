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

type overlaySelection =
  | Learn
  | Discuss
  | Complete(TargetDetails.completionType);

let completionTypeToString = (completionType, targetStatus) =>
  switch (
    targetStatus |> TargetStatus.status,
    completionType: TargetDetails.completionType,
  ) {
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
      course,
      overlaySelection,
      setOverlaySelection,
      targetDetails,
      targetStatus,
    ) => {
  let completionType = targetDetails |> TargetDetails.computeCompletionType;

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

let showQuizSection = (target, targetDetails, authenticityToken) => {
  let quizQuestions = targetDetails |> TargetDetails.quizQuestions;
  <CourseShow__Quiz target quizQuestions authenticityToken />;
};

let completeSection =
    (completionType, target, targetDetails, authenticityToken, targetStatus) =>
  <div>
    {
      switch (
        targetStatus |> TargetStatus.status,
        completionType: TargetDetails.completionType,
      ) {
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

let targetStatusClass = (prefix, targetStatus) =>
  prefix
  ++ (targetStatus |> TargetStatus.statusToString |> Js.String.toLowerCase);

let targetStatusClasses = targetStatus =>
  "curriculum__target-status text-xs md:text-sm py-1 px-2 md:px-4 "
  ++ targetStatusClass("curriculum__target-status--", targetStatus);

let overlayHeaderTitleCardClasses = targetStatus =>
  "course-overlay__header-title-card flex justify-between items-center px-3 py-5 md:p-6 mb-5 md:mb-7 "
  ++ targetStatusClass("course-overlay__header-title-card--", targetStatus);

let overlayStatus = (closeOverlayCB, target, targetStatus) =>
  <div className={overlayHeaderTitleCardClasses(targetStatus)}>
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
      <div className={targetStatusClasses(targetStatus)}>
        {targetStatus |> CourseShow__TargetStatus.statusToString |> str}
      </div>
    </div>
  </div>;

let pushUrl = (course, selectedTargetId) =>
  switch (selectedTargetId) {
  | Some(targetId) => ReasonReactRouter.push("/targets/" ++ targetId)
  | None => ReasonReactRouter.push("/courses/" ++ (course |> Course.id))
  };

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
    pushUrl(course, Some(target |> Target.id));
    Some(() => pushUrl(course, None));
  });

  React.useEffect(() => {
    ScrollLock.activate();
    Some(() => ScrollLock.deActivate());
  });

  <div
    className="fixed z-20 top-0 left-0 w-full h-full overflow-y-scroll bg-white">
    <div className="bg-gray-100 border-b border-gray-400 px-3">
      <div className="course-overlay__header-container mx-auto">
        {overlayStatus(closeOverlayCB, target, targetStatus)}
        {
          switch (targetDetails) {
          | Some(targetDetails) =>
            overlaySelectionOptions(
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
          switch (overlaySelection) {
          | Learn =>
            <CourseShow__Learn
              target
              targetDetails
              authenticityToken
              targetStatus
            />
          | Discuss => <CourseShow__Discuss target targetDetails />
          | Complete(completionType) =>
            completeSection(
              completionType,
              target,
              targetDetails,
              authenticityToken,
              targetStatus,
            )
          }

        | None => "Loading..." |> str
        }
      }
    </div>
  </div>;
};