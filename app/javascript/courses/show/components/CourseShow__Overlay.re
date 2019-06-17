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

let scrollCompleteButtonIntoView = () => {
  let element =
    Webapi.Dom.document
    |> Webapi.Dom.Document.getElementById("auto-verify-target");
  (
    switch (element) {
    | Some(e) =>
      Webapi.Dom.Element.scrollIntoView(e);
      e->Webapi.Dom.Element.setClassName("mt-4 complete-button-selected");
    | None => ()
    }
  )
  |> ignore;
  None;
};

let handleTablink = (setOverlaySelection, setScrollToSelection, _event) => {
  setOverlaySelection(_ => Learn);
  setScrollToSelection(scrollToSelection => !scrollToSelection);
};

let tabButton =
    (selection, overlaySelection, setOverlaySelection, targetStatus) =>
  <span
    key={"select-" ++ (selection |> selectionToString(targetStatus))}
    className={tabClasses(selection, overlaySelection)}
    onClick={_e => setOverlaySelection(_ => selection)}>
    {selection |> selectionToString(targetStatus) |> str}
  </span>;

let tabLink =
    (
      selection,
      overlaySelection,
      setOverlaySelection,
      targetStatus,
      setScrollToSelection,
    ) =>
  <span
    onClick={handleTablink(setOverlaySelection, setScrollToSelection)}
    className={tabClasses(selection, overlaySelection)}>
    {selection |> selectionToString(targetStatus) |> str}
  </span>;

let overlaySelectionOptions =
    (
      course,
      overlaySelection,
      setOverlaySelection,
      targetDetails,
      targetStatus,
      setScrollToSelection,
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
        tabLink(
          Complete(_completionTypes),
          overlaySelection,
          setOverlaySelection,
          targetStatus,
          setScrollToSelection,
        )

      | (Locked(_), _) => React.null
      }
    }
  </div>;
};

let addSubmission =
    (
      target,
      setTargetDetails,
      addSubmissionCB,
      submission,
      submissionAttachments,
    ) => {
  setTargetDetails(targetDetails =>
    switch (targetDetails) {
    | Some(targetDetails) =>
      Some({
        ...targetDetails,
        TargetDetails.submissions: [
          submission,
          ...targetDetails |> TargetDetails.submissions,
        ],
        submissionAttachments:
          submissionAttachments
          @ (targetDetails |> TargetDetails.submissionAttachments),
      })
    | None => None
    }
  );

  addSubmissionCB(target |> Target.id |> TargetStatus.makeSubmitted);
};

let addVerifiedSubmission =
    (target, setTargetDetails, addSubmissionCB, submission) => {
  setTargetDetails(targetDetails =>
    switch (targetDetails) {
    | Some(targetDetails) =>
      Some({
        ...targetDetails,
        TargetDetails.submissions: [
          submission,
          ...targetDetails |> TargetDetails.submissions,
        ],
      })
    | None => None
    }
  );

  addSubmissionCB(target |> Target.id |> TargetStatus.makePassed);
};

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
let overlayContentClasses = bool => bool ? "" : "hidden";

let learnSection =
    (target, targetDetails, authenticityToken, targetStatus, overlaySelection) =>
  <div className={overlayContentClasses(overlaySelection == Learn)}>
    <CourseShow__Learn targetDetails />
  </div>;

let discussSection = (target, targetDetails, overlaySelection) =>
  <div className={overlayContentClasses(overlaySelection == Discuss)}>
    <CourseShow__Discuss target targetDetails />
  </div>;

let completeSectionClasses =
    (overlaySelection, completionType: TargetDetails.completionType) =>
  switch (overlaySelection, completionType) {
  | (Learn, Evaluated | TakeQuiz)
  | (Discuss, Evaluated | TakeQuiz | MarkAsComplete | LinkToComplete) => "hidden"
  | (Learn, MarkAsComplete | LinkToComplete)
  | (Complete(_), Evaluated | TakeQuiz | MarkAsComplete | LinkToComplete) => ""
  };

let completeSection =
    (
      overlaySelection,
      target,
      targetDetails,
      setTargetDetails,
      authenticityToken,
      targetStatus,
      addSubmissionCB,
    ) => {
  let completionType = targetDetails |> TargetDetails.computeCompletionType;
  let addVerifiedSubmissionCB =
    addVerifiedSubmission(target, setTargetDetails, addSubmissionCB);
  <div className={completeSectionClasses(overlaySelection, completionType)}>
    {
      switch (targetStatus |> TargetStatus.status, completionType) {
      | (Pending, Evaluated) =>
        <CourseShow__SubmissionForm
          authenticityToken
          target
          addSubmissionCB={
            addSubmission(target, setTargetDetails, addSubmissionCB)
          }
        />
      | (Pending, TakeQuiz) =>
        <CourseShow__Quiz
          target
          targetDetails
          authenticityToken
          addSubmissionCB=addVerifiedSubmissionCB
        />

      | (Submitted | Passed | Failed, Evaluated | TakeQuiz) =>
        <CourseShow__SubmissionsAndFeedbacks targetDetails />
      | (
          Pending | Submitted | Passed | Failed,
          LinkToComplete | MarkAsComplete,
        ) =>
        <CourseShow__AutoVerify
          target
          targetDetails
          authenticityToken
          targetStatus
          addSubmissionCB=addVerifiedSubmissionCB
        />
      | (Locked(_), Evaluated | TakeQuiz | MarkAsComplete | LinkToComplete) => React.null
      }
    }
  </div>;
};

[@react.component]
let make =
    (
      ~target,
      ~course,
      ~targetStatus,
      ~authenticityToken,
      ~closeOverlayCB,
      ~addSubmissionCB,
    ) => {
  let (targetDetails, setTargetDetails) = React.useState(() => None);
  let (overlaySelection, setOverlaySelection) = React.useState(() => Learn);
  let (scrollToSelection, setScrollToSelection) = React.useState(() => false);

  React.useEffect1(scrollCompleteButtonIntoView, [|scrollToSelection|]);

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
              setScrollToSelection,
            )
          | None =>
            <div className="text-center text-sm font-semibold">
              {"Loading..." |> str}
            </div>
          }
        }
      </div>
    </div>
    {
      switch (targetDetails) {
      | Some(targetDetails) =>
        <div
          className="container mx-auto mt-6 md:mt-8 max-w-3xl px-3 md:px-0 pb-8">
          {
            learnSection(
              target,
              targetDetails,
              authenticityToken,
              targetStatus,
              overlaySelection,
            )
          }
          {discussSection(target, targetDetails, overlaySelection)}
          {
            completeSection(
              overlaySelection,
              target,
              targetDetails,
              setTargetDetails,
              authenticityToken,
              targetStatus,
              addSubmissionCB,
            )
          }
        </div>

      | None => "Loading..." |> str
      }
    }
  </div>;
};