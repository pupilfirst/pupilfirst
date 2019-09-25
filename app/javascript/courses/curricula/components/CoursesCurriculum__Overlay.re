[@bs.config {jsx: 3}];

exception UnexpectedSubmissionStatus(string);

[%bs.raw {|require("./CoursesCurriculum__Overlay.css")|}];

open CoursesCurriculum__Types;
module TargetStatus = CoursesCurriculum__TargetStatus;

let str = React.string;

let closeOverlay = course =>
  ReasonReactRouter.push(
    "/courses/" ++ (course |> Course.id) ++ "/curriculum",
  );

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
  | (
      Submitted | Passed | Failed | Locked(CourseLocked | AccessLocked),
      Evaluated | TakeQuiz,
    ) => "Submissions & Feedback"
  | (Submitted | Passed | Failed, LinkToComplete | MarkAsComplete) => "Completed"
  | (Locked(_), Evaluated | TakeQuiz | LinkToComplete | MarkAsComplete) => "Locked"
  };

let selectionToString = (targetStatus, overlaySelection) =>
  switch (overlaySelection) {
  | Learn => "Learn"
  | Discuss => "Discuss"
  | Complete(completionType) =>
    completionTypeToString(completionType, targetStatus)
  };

let selectableTabs = targetDetails =>
  targetDetails |> TargetDetails.communities |> ListUtils.isNotEmpty ?
    [Learn, Discuss] : [Learn];

let tabClasses = (selection, overlaySelection) =>
  "course-overlay__body-tab-item px-3 py-4 flex w-full items-center justify-center text-sm -mx-px font-semibold"
  ++ (
    overlaySelection == selection ?
      " course-overlay__body-tab-item--selected" :
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
      overlaySelection,
      setOverlaySelection,
      targetDetails,
      targetStatus,
      setScrollToSelection,
    ) => {
  let completionType = targetDetails |> TargetDetails.computeCompletionType;

  <div className="flex justify-between max-w-3xl mx-auto -mb-px mt-5 md:mt-7">
    {
      selectableTabs(targetDetails)
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
      | (Pending | Submitted | Passed | Failed, Evaluated | TakeQuiz) =>
        tabButton(
          Complete(completionType),
          overlaySelection,
          setOverlaySelection,
          targetStatus,
        )
      | (Locked(CourseLocked | AccessLocked), Evaluated | TakeQuiz) =>
        targetDetails |> TargetDetails.submissions |> ListUtils.isNotEmpty ?
          tabButton(
            Complete(completionType),
            overlaySelection,
            setOverlaySelection,
            targetStatus,
          ) :
          React.null
      | (
          Pending | Submitted | Passed | Failed,
          LinkToComplete | MarkAsComplete,
        ) =>
        tabLink(
          Complete(completionType),
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

  switch (submission |> Submission.status) {
  | MarkedAsComplete =>
    addSubmissionCB(
      LatestSubmission.make(~pending=false, ~targetId=target |> Target.id),
    )
  | Pending =>
    addSubmissionCB(
      LatestSubmission.make(~pending=true, ~targetId=target |> Target.id),
    )
  | Passed =>
    raise(
      UnexpectedSubmissionStatus(
        "CoursesCurriculum__Overlay.addSubmission cannot handle a submsision with status Passed",
      ),
    )
  | Failed =>
    raise(
      UnexpectedSubmissionStatus(
        "CoursesCurriculum__Overlay.addSubmission cannot handle a submsision with status Failed",
      ),
    )
  };
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

  addSubmissionCB(
    LatestSubmission.make(~pending=false, ~targetId=target |> Target.id),
  );
};

let targetStatusClass = (prefix, targetStatus) =>
  prefix
  ++ (targetStatus |> TargetStatus.statusToString |> Js.String.toLowerCase);

let targetStatusClasses = targetStatus =>
  "curriculum__target-status bg-white text-xs mt-2 md:mt-0 py-1 px-2 md:px-4 "
  ++ targetStatusClass("curriculum__target-status--", targetStatus);

let overlayHeaderTitleCardClasses = targetStatus =>
  "course-overlay__header-title-card relative flex justify-between items-center px-3 py-5 md:p-6 "
  ++ targetStatusClass("course-overlay__header-title-card--", targetStatus);

let overlayStatus = (course, target, targetStatus) =>
  <div className={overlayHeaderTitleCardClasses(targetStatus)}>
    <button
      className={
        "course-overlay__close xl:absolute flex flex-col items-center justify-center absolute rounded-t-lg lg:rounded-t-none lg:rounded-b-lg leading-tight px-4 py-1 h-8 lg:h-full cursor-pointer border border-b-0 lg:border-transparent lg:border-t-0 lg:shadow hover:text-gray-900 hover:shadow-md focus:border-gray-300 focus:outline-none focus:shadow-inner "
        ++ targetStatusClass("course-overlay__close--", targetStatus)
      }
      onClick={_e => closeOverlay(course)}>
      <Icon className="if i-times-light text-xl lg:text-2xl mt-1 lg:mt-0" />
      <span className="text-xs hidden lg:inline-block mt-px">
        {"Close" |> str}
      </span>
    </button>
    <div
      className="w-full flex flex-wrap md:flex-no-wrap items-center justify-between relative">
      <h1 className="text-base leading-snug md:mr-6 md:text-xl">
        {target |> Target.title |> str}
      </h1>
      <div className={targetStatusClasses(targetStatus)}>
        {targetStatus |> TargetStatus.statusToString |> str}
      </div>
    </div>
  </div>;

let renderLockReason = reason =>
  <div
    className="mx-auto text-center bg-gray-900 text-white max-w-fc px-4 py-2 text-sm font-semibold relative z-10 rounded-b-lg">
    <i className="fas fa-lock text-lg" />
    <span className="ml-2">
      {reason |> TargetStatus.lockReasonToString |> str}
    </span>
  </div>;

let prerequisitesIncomplete =
    (reason, target, targets, statusOfTargets, changeTargetCB) => {
  let prerequisiteTargetIds = target |> Target.prerequisiteTargetIds;
  let prerequisiteTargets =
    targets
    |> List.filter(target =>
         (target |> Target.id)->List.mem(prerequisiteTargetIds)
       );
  <div className="relative px-3 md:px-0">
    {renderLockReason(reason)}
    <div
      className="course-overlay__prerequisite-targets z-10 max-w-3xl mx-auto bg-white text-center rounded-lg overflow-hidden shadow mt-6">
      {
        prerequisiteTargets
        |> List.map(target => {
             let targetStatus =
               statusOfTargets
               |> List.find(ts =>
                    ts |> TargetStatus.targetId == (target |> Target.id)
                  );

             <div
               ariaLabel={"Select Target " ++ (target |> Target.id)}
               key={target |> Target.id}
               className="bg-white border-t px-6 py-4 relative z-10 flex items-center justify-between hover:bg-gray-200 hover:text-primary-500 cursor-pointer"
               onClick={_ => changeTargetCB(target)}>
               <span className="font-semibold text-left leading-snug">
                 {target |> Target.title |> str}
               </span>
               <span className={targetStatusClasses(targetStatus)}>
                 {targetStatus |> TargetStatus.statusToString |> str}
               </span>
             </div>;
           })
        |> Array.of_list
        |> React.array
      }
    </div>
  </div>;
};

let handleLocked =
    (target, targets, targetStatus, statusOfTargets, changeTargetCB) =>
  switch (targetStatus |> TargetStatus.status) {
  | Locked(reason) =>
    switch (reason) {
    | PrerequisitesIncomplete =>
      prerequisitesIncomplete(
        reason,
        target,
        targets,
        statusOfTargets,
        changeTargetCB,
      )
    | CourseLocked
    | AccessLocked
    | LevelLocked
    | PreviousLevelMilestonesIncomplete => renderLockReason(reason)
    }
  | Pending
  | Submitted
  | Passed
  | Failed => React.null
  };

let overlayContentClasses = bool => bool ? "" : "hidden";

let learnSection = (targetDetails, overlaySelection) =>
  <div className={overlayContentClasses(overlaySelection == Learn)}>
    <CoursesCurriculum__Learn targetDetails />
  </div>;

let discussSection = (target, targetDetails, overlaySelection) =>
  <div className={overlayContentClasses(overlaySelection == Discuss)}>
    <CoursesCurriculum__Discuss
      targetId={target |> Target.id}
      communities={targetDetails |> TargetDetails.communities}
    />
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
      evaluationCriteria,
      gradeLabels,
      coaches,
      users,
    ) => {
  let completionType = targetDetails |> TargetDetails.computeCompletionType;
  let addVerifiedSubmissionCB =
    addVerifiedSubmission(target, setTargetDetails, addSubmissionCB);
  <div className={completeSectionClasses(overlaySelection, completionType)}>
    {
      switch (targetStatus |> TargetStatus.status, completionType) {
      | (Pending, Evaluated) =>
        [|
          <CoursesCurriculum__CompletionInstructions
            key="completion-instructions"
            targetDetails
            title="Instructions"
          />,
          <CoursesCurriculum__SubmissionForm
            key="courses-curriculum-submission-form"
            authenticityToken
            target
            addSubmissionCB={
              addSubmission(target, setTargetDetails, addSubmissionCB)
            }
          />,
        |]
        |> React.array
      | (Pending, TakeQuiz) =>
        [|
          <CoursesCurriculum__CompletionInstructions
            key="completion-instructions"
            targetDetails
            title="Instructions"
          />,
          <CoursesCurriculum__Quiz
            key="courses-curriculum-quiz"
            target
            targetDetails
            authenticityToken
            addSubmissionCB=addVerifiedSubmissionCB
          />,
        |]
        |> React.array

      | (
          Submitted | Passed | Failed | Locked(CourseLocked | AccessLocked),
          Evaluated | TakeQuiz,
        ) =>
        <CoursesCurriculum__SubmissionsAndFeedback
          targetDetails
          target
          authenticityToken
          gradeLabels
          evaluationCriteria
          addSubmissionCB={
            addSubmission(target, setTargetDetails, addSubmissionCB)
          }
          targetStatus
          coaches
          users
        />
      | (
          Pending | Submitted | Passed | Failed,
          LinkToComplete | MarkAsComplete,
        ) =>
        <CoursesCurriculum__AutoVerify
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

let renderPendingStudents = (pendingUserIds, users) =>
  <div className="max-w-3xl mx-auto text-center mt-4">
    <div className="font-semibold text-md">
      {"You have team members who are yet to complete this target:" |> str}
    </div>
    <div className="flex justify-center flex-wrap">
      {
        pendingUserIds
        |> List.map(studentId => {
             let user =
               users
               |> ListUtils.unsafeFind(
                    u => u |> User.id == studentId,
                    "Unable to find user with id "
                    ++ studentId
                    ++ "in CoursesCurriculum__Overlay",
                  );

             <div
               title={(user |> User.name) ++ " has not completed this target."}
               className="w-10 h-10 rounded-full border border-yellow-400 flex items-center justify-center overflow-hidden mx-1 shadow-md flex-shrink-0 mt-2">
               <img src={user |> User.avatarUrl} />
             </div>;
           })
        |> Array.of_list
        |> React.array
      }
    </div>
  </div>;

let handlePendingStudents = (targetStatus, targetDetails, users) =>
  switch (targetDetails, targetStatus |> TargetStatus.status) {
  | (Some(targetDetails), Submitted | Passed) =>
    let pendingUserIds = targetDetails |> TargetDetails.pendingUserIds;
    pendingUserIds |> ListUtils.isNotEmpty ?
      renderPendingStudents(pendingUserIds, users) : React.null;
  | (Some(_) | None, Locked(_) | Pending | Submitted | Passed | Failed) => React.null
  };

[@react.component]
let make =
    (
      ~target,
      ~course,
      ~targetStatus,
      ~authenticityToken,
      ~addSubmissionCB,
      ~targets,
      ~statusOfTargets,
      ~changeTargetCB,
      ~users,
      ~evaluationCriteria,
      ~coaches,
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
    ScrollLock.activate();
    Some(() => ScrollLock.deactivate());
  });

  <div
    className="fixed z-30 top-0 left-0 w-full h-full overflow-y-scroll bg-white">
    <div className="bg-gray-100 border-b border-gray-400 px-3">
      <div className="course-overlay__header-container pt-12 lg:pt-0 mx-auto">
        {overlayStatus(course, target, targetStatus)}
        {
          handleLocked(
            target,
            targets,
            targetStatus,
            statusOfTargets,
            changeTargetCB,
          )
        }
        {handlePendingStudents(targetStatus, targetDetails, users)}
        {
          switch (targetDetails) {
          | Some(targetDetails) =>
            overlaySelectionOptions(
              overlaySelection,
              setOverlaySelection,
              targetDetails,
              targetStatus,
              setScrollToSelection,
            )
          | None =>
            <div
              className="course-overlay__skeleton-head-container max-w-3xl w-full mx-auto">
              <div
                className="course-overlay__skeleton-head-wrapper bg-white h-13 flex items-center justify-between border border-b-0 rounded-t-lg mt-5 md:mt-7">
                <div
                  className="course-overlay__skeleton-line-placeholder-sm w-1/3 mx-8 skeleton-animate"
                />
                <div
                  className="course-overlay__skeleton-line-placeholder-sm w-1/3 mx-8 skeleton-animate"
                />
                <div
                  className="course-overlay__skeleton-line-placeholder-sm w-1/3 mx-8 skeleton-animate"
                />
              </div>
            </div>
          }
        }
      </div>
    </div>
    {
      switch (targetDetails) {
      | Some(targetDetails) =>
        <div
          className="container mx-auto mt-6 md:mt-8 max-w-3xl px-4 lg:px-0 pb-8">
          {learnSection(targetDetails, overlaySelection)}
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
              evaluationCriteria,
              course |> Course.gradeLabels,
              coaches,
              users,
            )
          }
        </div>

      | None =>
        <div
          className="course-overlay__skeleton-body-container max-w-3xl w-full pb-4 mx-auto">
          <div
            className="course-overlay__skeleton-body-wrapper mt-8 px-3 lg:px-0">
            <div
              className="course-overlay__skeleton-line-placeholder-md mt-4 w-2/4 skeleton-animate"
            />
            <div
              className="course-overlay__skeleton-line-placeholder-sm mt-4 skeleton-animate"
            />
            <div
              className="course-overlay__skeleton-line-placeholder-sm mt-4 skeleton-animate"
            />
            <div
              className="course-overlay__skeleton-line-placeholder-sm mt-4 w-3/4 skeleton-animate"
            />
            <div
              className="course-overlay__skeleton-image-placeholder mt-5 skeleton-animate"
            />
            <div
              className="course-overlay__skeleton-line-placeholder-sm mt-4 w-2/5 skeleton-animate"
            />
          </div>
          <div
            className="course-overlay__skeleton-body-wrapper mt-8 px-3 lg:px-0">
            <div
              className="course-overlay__skeleton-line-placeholder-sm mt-4 w-3/4 skeleton-animate"
            />
            <div
              className="course-overlay__skeleton-line-placeholder-sm mt-4 skeleton-animate"
            />
            <div
              className="course-overlay__skeleton-line-placeholder-sm mt-4 w-3/4 skeleton-animate"
            />
          </div>
        </div>
      }
    }
  </div>;
};