exception UnexpectedSubmissionStatus(string)
exception UnexpectedResponse(int)

%%raw(`import "./CoursesCurriculum__Overlay.css"`)

open CoursesCurriculum__Types

module TargetStatus = CoursesCurriculum__TargetStatus

@module("../images/no-peer-submissions.svg") external noPeerSubmissionIcon: string = "default"
@module("../images/assignment-discussion-icon.svg")
external assignmentDiscussionIcon: string = "default"

let str = React.string

let t = I18n.t(~scope="components.CoursesCurriculum__Overlay")
let ts = I18n.t(~scope="shared")

module Item = {
  type t = DiscussionSubmission.t
}

module PagedSubmission = Pagination.Make(Item)

type loading = Unloaded | Loading | Loaded

type tab =
  | Learn
  | Discuss
  | Complete(TargetDetails.completionType)

type state = {
  loading: LoadingV2.t,
  targetDetails: option<TargetDetails.t>,
  tab: tab,
  peerSubmissions: PagedSubmission.t,
  totalEntriesCount: int,
}

type action =
  | Select(tab)
  | ResetState
  | SetTargetDetails(TargetDetails.t)
  | AddSubmission(Target.role)
  | PerformQuickNavigation
  | BeginReloading
  | BeginLoadingMore
  | LoadSubmissions(option<string>, bool, array<DiscussionSubmission.t>, int)

let initialState = {
  loading: LoadingV2.empty(),
  targetDetails: None,
  tab: Learn,
  peerSubmissions: Unloaded,
  totalEntriesCount: 0,
}

let reducer = (state, action) =>
  switch action {
  | Select(tab) => {...state, tab}
  | ResetState => initialState
  | SetTargetDetails(targetDetails) => {
      ...state,
      targetDetails: Some(targetDetails),
    }
  | PerformQuickNavigation => initialState
  | AddSubmission(role) =>
    switch role {
    | Target.Student => state
    | Team => {
        ...state,
        targetDetails: state.targetDetails |> OptionUtils.map(TargetDetails.clearPendingUserIds),
      }
    }
  | BeginReloading => {...state, loading: LoadingV2.setReloading(state.loading)}
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | LoadSubmissions(endCursor, hasNextPage, newSubmissions, totalEntriesCount) =>
    let updatedSubmissions = switch state.loading {
    | LoadingMore =>
      Js.Array2.concat(PagedSubmission.toArray(state.peerSubmissions), newSubmissions)
    | Reloading(_) => newSubmissions
    }

    {
      ...state,
      peerSubmissions: PagedSubmission.make(updatedSubmissions, hasNextPage, endCursor),
      loading: LoadingV2.setNotLoading(state.loading),
      totalEntriesCount,
    }
  }

let closeOverlay = course =>
  RescriptReactRouter.push("/courses/" ++ ((course |> Course.id) ++ "/curriculum"))

module DiscussionSubmissionsQuery = %graphql(`
    query DiscussionSubmissionsQuery($targetId: ID!, $after: String) {
      discussionSubmissions(targetId: $targetId, first: 10, after: $after) {
        nodes {
          id,
          targetId,
          createdAt,
          hiddenAt,
          checklist,
          files {
            id,
            name,
            url
          },
          userNames,
          users {
            id,
            name,
            title,
            avatarUrl
          }
          teamName,
          comments {
            id,
            userId,
            submissionId,
            comment,
            reactions {
              id,
              userId,
              reactionableId,
              reactionValue,
              reactionableType,
              userName,
              updatedAt
            },
            moderationReports {
              id,
              userId,
              reportableId,
              reason,
              reportableType
            },
            user {
              id
              name
              title
              avatarUrl
            },
            createdAt
            hiddenAt
            hiddenById
          },
          reactions {
            id,
            userId,
            reactionableId,
            reactionValue,
            reactionableType,
            userName,
            updatedAt
          }
          anonymous
          pinned
          moderationReports {
            id,
            userId,
            reportableId,
            reason,
            reportableType
          }
        }
        pageInfo {
          endCursor,
          hasNextPage
        }
        totalCount
      }
    }
  `)

let getDiscussionSubmissions = (send, cursor, targetId) => {
  DiscussionSubmissionsQuery.make({targetId, after: cursor})
  |> Js.Promise.then_(response => {
    send(
      LoadSubmissions(
        response["discussionSubmissions"]["pageInfo"]["endCursor"],
        response["discussionSubmissions"]["pageInfo"]["hasNextPage"],
        Js.Array.map(DiscussionSubmission.decode, response["discussionSubmissions"]["nodes"]),
        response["discussionSubmissions"]["totalCount"],
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let reloadSubmissions = (send, targetId) => {
  send(BeginReloading)
  getDiscussionSubmissions(send, None, targetId)
}

let handleUrlParam = (~key, ~prefix, send, targetDetails) => {
  let paramValue = DomUtils.getUrlParam(~key)
  let elementId = prefix ++ Belt.Option.getWithDefault(paramValue, "")
  let element = Webapi.Dom.document->Webapi.Dom.Document.getElementById(elementId)

  switch element {
  | Some(element) => {
      let completionType = TargetDetails.computeCompletionType(targetDetails)
      send(Select(Complete(completionType)))

      Webapi.Dom.Element.scrollIntoView(element)
      element->Webapi.Dom.Element.classList->Webapi.Dom.DomTokenList.add("element--highlighted")
    }
  | None => Rollbar.error(prefix ++ " not found")
  }
}

let loadTargetDetails = (target, currentUser, send, ()) => {
  {
    open Js.Promise

    Fetch.fetch("/targets/" ++ ((target |> Target.id) ++ "/details_v2"))
    |> then_(Fetch.Response.json)
    |> then_(json => {
      let targetDetails = TargetDetails.decode(json)

      send(SetTargetDetails(targetDetails))

      // Load peer submissions only if the target has discussion enabled and the current user is a participant.
      if CurrentUser.isParticipant(currentUser) && TargetDetails.discussion(targetDetails) {
        reloadSubmissions(send, Target.id(target))
      }

      let hasCommentParam = DomUtils.hasUrlParam(~key="comment_id")
      let hasSubmissionParam = DomUtils.hasUrlParam(~key="submission_id")

      if hasCommentParam && hasSubmissionParam {
        handleUrlParam(~key="comment_id", ~prefix="comment-", send, targetDetails)
      }

      if hasSubmissionParam && !hasCommentParam {
        handleUrlParam(~key="submission_id", ~prefix="submission-", send, targetDetails)
      }

      resolve(targetDetails)
    })
  } |> ignore

  None
}

let submissionsLoadedData = (totalSubmissionsCount, loadedSubmissionsCount) =>
  <p
    tabIndex=0
    className="inline-block mt-8 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
    {str(
      totalSubmissionsCount == loadedSubmissionsCount
        ? t(~count=loadedSubmissionsCount, "submissions_fully_loaded_text")
        : t(
            ~count=loadedSubmissionsCount,
            ~variables=[
              ("total_submissions", string_of_int(totalSubmissionsCount)),
              ("loaded_submissions_count", string_of_int(loadedSubmissionsCount)),
            ],
            "submissions_partially_loaded_text",
          ),
    )}
  </p>

let submissionsList = (submissions, state, currentUser, callBack) => {
  <div className="discussion-submissions__container space-y-16">
    {ArrayUtils.isEmpty(submissions)
      ? <div className="bg-gray-50/50 rounded-lg mt-2 p-4">
          <img className="w-64 mx-auto" src=noPeerSubmissionIcon />
          <p className="text-center text-gray-600"> {t("no_peer_submissions")->str} </p>
        </div>
      : {
          Js.Array2.map(submissions, submission =>
            <CoursesCurriculum__DiscussSubmission
              key={submission->DiscussionSubmission.id} currentUser submission callBack
            />
          )
        }->React.array}
    {ReactUtils.nullIf(
      <div className="text-center pb-4">
        {submissionsLoadedData(state.totalEntriesCount, Array.length(submissions))}
      </div>,
      ArrayUtils.isEmpty(submissions),
    )}
  </div>
}

let completionTypeToString = (completionType, targetStatus) =>
  switch (targetStatus |> TargetStatus.status, (completionType: TargetDetails.completionType)) {
  | (Pending, Evaluated) => t("completion_tab_complete")
  | (Pending, TakeQuiz) => t("completion_tab_take_quiz")
  | (Pending, NoAssignment) => ""
  | (Pending, SubmitForm) => t("completion_tab_submit_form")
  | (
      PendingReview
      | Completed
      | Rejected
      | Locked(CourseLocked | AccessLocked),
      Evaluated,
    ) =>
    t("completion_tab_submissions")
  | (
      PendingReview
      | Completed
      | Rejected
      | Locked(CourseLocked | AccessLocked),
      TakeQuiz,
    ) =>
    t("completion_tab_quiz_result")
  | (
      PendingReview
      | Completed
      | Rejected
      | Locked(CourseLocked | AccessLocked),
      SubmitForm,
    ) =>
    t("completion_tab_form_response")
  | (PendingReview | Completed | Rejected, NoAssignment) => t("completion_tab_completed")
  | (Locked(_), Evaluated | TakeQuiz | NoAssignment | SubmitForm) => t("completion_tab_locked")
  }

let tabToString = (targetStatus, tab) =>
  switch tab {
  | Learn => t("learn_tab")
  | Discuss => t("discuss_tab")
  | Complete(completionType) => completionTypeToString(completionType, targetStatus)
  }

let selectableTabs = targetDetails =>
  TargetDetails.communities(targetDetails) == [] ? [Learn] : [Learn, Discuss]

let tabClasses = (selection, tab) =>
  "course-overlay__body-tab-item p-2 md:px-3 md:py-4 flex w-full items-center justify-center text-sm -mx-px font-semibold focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500" ++ (
    tab == selection
      ? " course-overlay__body-tab-item--selected"
      : " bg-gray-50 hover:text-primary-400 hover:bg-gray-50 focus:text-primary-400 focus:bg-gray-50 cursor-pointer"
  )

let scrollCompleteButtonIntoViewEventually = () => Js.Global.setTimeout(() => {
    let element = Webapi.Dom.document->Webapi.Dom.Document.getElementById("auto-verify-target")
    switch element {
    | Some(e) =>
      Webapi.Dom.Element.scrollIntoView(e)
      e->Webapi.Dom.Element.setClassName("mt-4 complete-button-selected")
    | None => Rollbar.error("Could not find the 'Complete' button to scroll to.")
    }
  }, 50) |> ignore

let handleTablink = (send, _event) => {
  send(Select(Learn))
  scrollCompleteButtonIntoViewEventually()
}

let tabButton = (tab, state, send, targetStatus) =>
  <button
    key={"select-" ++ (tab |> tabToString(targetStatus))}
    role="tab"
    ariaSelected={tab == state.tab}
    className={tabClasses(tab, state.tab)}
    onClick={_e => send(Select(tab))}>
    {tab |> tabToString(targetStatus) |> str}
  </button>

let tabLink = (tab, state, send, targetStatus) =>
  <button onClick={handleTablink(send)} className={tabClasses(tab, state.tab)}>
    {tab |> tabToString(targetStatus) |> str}
  </button>

let tabOptions = (state, send, targetDetails, targetStatus) => {
  let completionType = targetDetails |> TargetDetails.computeCompletionType
  <div role="tablist" className="flex justify-between max-w-3xl mx-auto -mb-px mt-5 md:mt-7">
    {selectableTabs(targetDetails)
    |> Js.Array.map(selection => tabButton(selection, state, send, targetStatus))
    |> React.array}
    {switch (targetStatus |> TargetStatus.status, completionType) {
    | (Pending | PendingReview | Completed | Rejected, Evaluated | TakeQuiz | SubmitForm) =>
      tabButton(Complete(completionType), state, send, targetStatus)
    | (Locked(CourseLocked | AccessLocked), Evaluated | TakeQuiz | SubmitForm) =>
      TargetDetails.submissions(targetDetails) != []
        ? tabButton(Complete(completionType), state, send, targetStatus)
        : React.null
    | (Pending | PendingReview | Completed | Rejected, NoAssignment) => React.null
    | (Locked(_), _) => React.null
    }}
  </div>
}

let addSubmission = (target, state, send, addSubmissionCB, submission) => {
  switch state.targetDetails {
  | Some(targetDetails) =>
    let newTargetDetails = targetDetails |> TargetDetails.addSubmission(submission)

    send(SetTargetDetails(newTargetDetails))
  | None => ()
  }

  switch submission |> Submission.status {
  | MarkedAsComplete =>
    addSubmissionCB(LatestSubmission.make(~pending=false, ~targetId=target |> Target.id))
  | Pending => addSubmissionCB(LatestSubmission.make(~pending=true, ~targetId=target |> Target.id))
  | Completed =>
    raise(
      UnexpectedSubmissionStatus(
        "CoursesCurriculum__Overlay.addSubmission cannot handle a submsision with status Completed",
      ),
    )
  | Rejected =>
    raise(
      UnexpectedSubmissionStatus(
        "CoursesCurriculum__Overlay.addSubmission cannot handle a submsision with status Rejected",
      ),
    )
  }
}

let addVerifiedSubmission = (target, state, send, addSubmissionCB, submission) => {
  switch state.targetDetails {
  | Some(targetDetails) =>
    let newTargetDetails = targetDetails |> TargetDetails.addSubmission(submission)
    send(SetTargetDetails(newTargetDetails))
  | None => ()
  }

  addSubmissionCB(LatestSubmission.make(~pending=false, ~targetId=target |> Target.id))
}

let targetStatusClass = (prefix, targetStatus) =>
  prefix ++ (targetStatus |> TargetStatus.statusClassesSufix)

let renderTargetStatus = targetStatus => {
  let className =
    "curriculum__target-status bg-white text-xs mt-2 md:mt-0 py-1 px-2 md:px-4 " ++
    targetStatusClass("curriculum__target-status--", targetStatus)

  ReactUtils.nullIf(
    <div className> {targetStatus |> TargetStatus.statusToString |> str} </div>,
    TargetStatus.isPending(targetStatus),
  )
}

let overlayHeaderTitleCardClasses = targetStatus =>
  "course-overlay__header-title-card relative flex justify-between items-center px-3 py-3 md:p-6 " ++
  targetStatusClass("course-overlay__header-title-card--", targetStatus)

let renderLocked = text =>
  <div
    className="mx-auto text-center bg-gray-900 text-white max-w-fc px-4 py-2 text-sm font-semibold relative z-10 rounded-b-lg">
    <i className="fas fa-lock text-lg" />
    <span className="ms-2"> {text |> str} </span>
  </div>
let overlayStatus = (course, target, targetStatus, preview) =>
  <div>
    <div className={overlayHeaderTitleCardClasses(targetStatus)}>
      <button
        ariaLabel={t("close_button")}
        className={"course-overlay__close xl:absolute flex flex-col items-center justify-center absolute rounded-t-lg lg:rounded-t-none lg:rounded-b-lg leading-tight px-4 py-1 h-8 lg:h-full cursor-pointer border border-b-0 lg:border-transparent lg:border-t-0 lg:shadow hover:text-gray-900 hover:shadow-md focus:border-gray-300 focus:outline-none focus:text-gray-900 " ++
        targetStatusClass("course-overlay__close--", targetStatus)}
        onClick={_e => closeOverlay(course)}>
        <Icon className="if i-times-regular text-xl lg:text-2xl mt-1 lg:mt-0" />
        <span className="text-xs hidden lg:inline-block mt-px"> {t("close_button")->str} </span>
      </button>
      <div className="w-full flex flex-wrap md:flex-nowrap items-center justify-between relative">
        <div
          className="flex flex-col md:flex-row items-start md:items-center font-medium leading-snug">
          {Target.milestone(target)
            ? <div
                className="flex items-center flex-shrink-0 text-xs font-medium bg-yellow-100 text-yellow-800 border border-yellow-300 px-1.5 md:px-2 py-1 rounded-md mr-2">
                <Icon className="if i-milestone-solid text-sm" />
                <span className="ms-1"> {ts("milestone_label")->str} </span>
              </div>
            : React.null}
          <h1 className="text-base leading-snug md:me-6 md:text-xl">
            {target |> Target.title |> str}
          </h1>
        </div>
        {renderTargetStatus(targetStatus)}
      </div>
    </div>
    {ReactUtils.nullUnless(<div> {renderLocked(t("preview_mode_text"))} </div>, preview)}
  </div>

let renderLockReason = reason => TargetStatus.lockReasonToString(reason)->renderLocked

let prerequisitesIncomplete = (reason, target, targets, statusOfTargets, send) => {
  let prerequisiteTargetIds = target |> Target.prerequisiteTargetIds

  let prerequisiteTargets =
    targets |> Js.Array.filter(target =>
      prerequisiteTargetIds |> Js.Array.includes(Target.id(target))
    )

  <div className="relative px-3 md:px-0">
    {renderLockReason(reason)}
    <div
      className="course-overlay__prerequisite-targets z-10 max-w-3xl mx-auto bg-white text-center rounded-lg overflow-hidden shadow mt-6">
      {prerequisiteTargets
      |> Js.Array.map(target => {
        let targetStatus =
          statusOfTargets |> ArrayUtils.unsafeFind(
            ts => ts |> TargetStatus.targetId == Target.id(target),
            "Could not find status of target with ID " ++ Target.id(target),
          )

        <Link
          onClick={_ => send(ResetState)}
          href={"/targets/" ++ (target |> Target.id)}
          ariaLabel={"Select Target " ++ (target |> Target.id)}
          key={target |> Target.id}
          className="bg-white border-t px-6 py-4 relative z-10 flex items-center justify-between hover:bg-gray-50 hover:text-primary-500 cursor-pointer">
          <span className="font-semibold  leading-snug"> {target |> Target.title |> str} </span>
          {renderTargetStatus(targetStatus)}
        </Link>
      })
      |> React.array}
    </div>
  </div>
}

let handleLocked = (target, targets, targetStatus, statusOfTargets, send) =>
  switch targetStatus |> TargetStatus.status {
  | Locked(reason) =>
    switch reason {
    | PrerequisitesIncomplete =>
      prerequisitesIncomplete(reason, target, targets, statusOfTargets, send)
    | CourseLocked
    | AccessLocked
    | SubmissionLimitReached(_) =>
      renderLockReason(reason)
    }
  | Pending
  | PendingReview
  | Completed
  | Rejected => React.null
  }

let overlayContentClasses = bool => bool ? "" : "hidden"

let addPageRead = (targetId, markReadCB) => {
  open Js.Promise
  Fetch.fetchWithInit(
    "/targets/" ++ (targetId ++ "/mark_as_read"),
    Fetch.RequestInit.make(
      ~method_=Post,
      ~headers=Fetch.HeadersInit.makeWithArray([
        ("X-CSRF-Token", AuthenticityToken.fromHead()),
        ("Content-Type", "application/json"),
      ]),
      ~credentials=Fetch.SameOrigin,
      (),
    ),
  )
  |> then_(response => {
    if Fetch.Response.ok(response) {
      markReadCB(targetId)
      resolve()
    } else {
      Js.Promise.reject(UnexpectedResponse(response->Fetch.Response.status))
    }
  })
  |> ignore
}

let learnSection = (
  send,
  targetDetails,
  targetRead,
  tab,
  author,
  courseId,
  targetId,
  markReadCB,
  targetStatus,
  completionType,
  preview,
) => {
  let suffixLinkInfo = switch (TargetStatus.status(targetStatus), completionType) {
  | (Pending | Rejected, TargetDetails.Evaluated) =>
    Some((Complete(completionType), t("learn_cta_submit_work"), "fas fa-feather-alt"))
  | (Pending | Rejected, TakeQuiz) =>
    Some((Complete(completionType), t("learn_cta_take_quiz"), "fas fa-tasks"))
  | (Pending | Rejected, SubmitForm) =>
    Some((Complete(completionType), t("learn_cta_submit_form"), "fas fa-feather-alt"))
  | (Pending | Rejected, NoAssignment) => None
  | (PendingReview | Completed | Locked(_), _anyCompletionType) => None
  }

  let linkToTab = Belt.Option.mapWithDefault(suffixLinkInfo, React.null, ((
    tab,
    linkText,
    iconClasses,
  )) => {
    <button
      onClick={_ => send(Select(tab))}
      className="cursor-pointer flex rounded btn-success text-base justify-center w-full font-semibold p-4 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500 curriculum-overlay__learn-submit-btn">
      <span>
        <FaIcon classes={iconClasses ++ " me-2"} />
        {str(linkText)}
      </span>
    </button>
  })

  <div className={overlayContentClasses(tab == Learn)}>
    <CoursesCurriculum__Learn targetDetails author courseId targetId />
    <div className="flex flex-wrap gap-4 mt-4">
      {targetRead
        ? <div
            className="flex rounded text-base italic space-x-2 bg-gray-50 text-gray-600 items-center justify-center w-full font-semibold p-3">
            <span title="Marked read" className="w-5 h-5 flex items-center justify-center">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                fill="currentColor"
                className="w-5 h-5 text-gray-500"
                viewBox="0 0 16 16">
                <path
                  d="M12.354 4.354a.5.5 0 0 0-.708-.708L5 10.293 1.854 7.146a.5.5 0 1 0-.708.708l3.5 3.5a.5.5 0 0 0 .708 0l7-7zm-4.208 7-.896-.897.707-.707.543.543 6.646-6.647a.5.5 0 0 1 .708.708l-7 7a.5.5 0 0 1-.708 0z"
                />
                <path d="m5.354 7.146.896.897-.707.707-.897-.896a.5.5 0 1 1 .708-.708z" />
              </svg>
            </span>
            <span> {str(t("marked_read"))} </span>
          </div>
        : <button
            onClick={_ => {
              addPageRead(targetId, markReadCB)
            }}
            className="btn btn-default flex space-x-2 text-base w-full p-3 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500 curriculum-overlay__learn-submit-btn"
            disabled={preview || !TargetStatus.readable(targetStatus)}>
            <span className="w-2 h-2 inline-block rounded-full bg-blue-600" />
            <span> {str(t("mark_as_read"))} </span>
          </button>}
      {linkToTab}
    </div>
  </div>
}

let discussSection = (target, targetDetails, tab) =>
  <div className={overlayContentClasses(tab == Discuss)}>
    <CoursesCurriculum__Discuss
      targetId={target |> Target.id} communities={targetDetails |> TargetDetails.communities}
    />
  </div>

let completeSectionClasses = (tab, completionType) =>
  switch (tab, completionType) {
  | (Learn, TargetDetails.Evaluated | TakeQuiz | SubmitForm)
  | (Discuss, Evaluated | TakeQuiz | NoAssignment | SubmitForm) => "hidden"
  | (Learn, NoAssignment)
  | (Complete(_), Evaluated | TakeQuiz | NoAssignment | SubmitForm) => ""
  }

let completeSection = (
  state,
  send,
  target,
  targetDetails,
  targetStatus,
  addSubmissionCB,
  evaluationCriteria,
  coaches,
  users,
  preview,
  completionType,
  currentUser,
) => {
  let addVerifiedSubmissionCB = addVerifiedSubmission(target, state, send, addSubmissionCB)
  let targetId = target->Target.id

  <div>
    <div className={completeSectionClasses(state.tab, completionType)}>
      {targetDetails->TargetDetails.discussion
        ? <div
            className="bg-primary-100 max-w-3xl mx-auto rounded-lg px-4 md:px-6 py-4 flex flex-col-reverse sm:flex-row items-start md:items-center justify-between">
            <div className="sm:me-12 mt-2 sm:mt-0">
              <h3 className="leading-tight font-semibold">
                {t("discussion_assignment_notice.title")->str}
              </h3>
              <p className="text-sm text-gray-600 pt-1">
                {t("discussion_assignment_notice.description")->str}
              </p>
            </div>
            <div className="shrink-0 w-16 sm:w-32 me-4 sm:me-0">
              <img className="object-contain mx-auto" src=assignmentDiscussionIcon />
            </div>
          </div>
        : React.null}
      <div className="max-w-3xl mx-auto">
        {switch (targetStatus |> TargetStatus.status, completionType) {
        | (Pending, Evaluated) =>
          [
            <CoursesCurriculum__CompletionInstructions
              key="completion-instructions" targetDetails title="Instructions"
            />,
            <CoursesCurriculum__SubmissionBuilder
              key="courses-curriculum-submission-form"
              target
              targetDetails
              checklist={targetDetails |> TargetDetails.checklist}
              addSubmissionCB={addSubmission(target, state, send, addSubmissionCB)}
              preview
            />,
          ] |> React.array
        | (Pending, TakeQuiz) =>
          [
            <CoursesCurriculum__CompletionInstructions
              key="completion-instructions" targetDetails title="Instructions"
            />,
            <CoursesCurriculum__Quiz
              key="courses-curriculum-quiz"
              target
              targetDetails
              addSubmissionCB=addVerifiedSubmissionCB
              preview
            />,
          ] |> React.array

        | (Pending, SubmitForm) =>
          [
            <CoursesCurriculum__CompletionInstructions
              key="completion-instructions" targetDetails title="Instructions"
            />,
            <CoursesCurriculum__SubmissionBuilder
              key="courses-curriculum-submission-form"
              target
              targetDetails
              checklist={targetDetails |> TargetDetails.checklist}
              addSubmissionCB={addSubmission(target, state, send, addSubmissionCB)}
              preview
            />,
          ] |> React.array

        | (
            PendingReview
            | Completed
            | Rejected
            | Locked(CourseLocked | AccessLocked),
            Evaluated | TakeQuiz | SubmitForm,
          ) =>
          <CoursesCurriculum__SubmissionsAndFeedback
            currentUser
            targetDetails
            target
            evaluationCriteria
            addSubmissionCB={addSubmission(target, state, send, addSubmissionCB)}
            targetStatus
            coaches
            users
            preview
            checklist={targetDetails |> TargetDetails.checklist}
          />
        | (Pending | PendingReview | Completed | Rejected, NoAssignment) => React.null
        | (Locked(_), Evaluated | TakeQuiz | NoAssignment | SubmitForm) => React.null
        }}
      </div>
      {targetDetails->TargetDetails.discussion && currentUser->CurrentUser.isParticipant
        ? <div className="border-t mt-12">
            <div className="max-w-3xl mx-auto">
              <h4 className="text-base md:text-lg font-semibold pt-12 pb-4">
                {t("submissions_peers")->str}
              </h4>
              <div>
                {switch state.peerSubmissions {
                | Unloaded =>
                  <div> {SkeletonLoading.multiple(~count=6, ~element=SkeletonLoading.card())} </div>
                | PartiallyLoaded(submissions, cursor) =>
                  <div>
                    {submissionsList(
                      submissions,
                      state,
                      currentUser,
                      getDiscussionSubmissions(send, None),
                    )}
                    {switch state.loading {
                    | LoadingMore =>
                      <div>
                        {SkeletonLoading.multiple(~count=1, ~element=SkeletonLoading.card())}
                      </div>
                    | Reloading(times) =>
                      ReactUtils.nullUnless(
                        <div className="pb-6">
                          <button
                            className="btn btn-primary-ghost cursor-pointer w-full"
                            onClick={_ => {
                              send(BeginLoadingMore)
                              getDiscussionSubmissions(send, Some(cursor), targetId)
                            }}>
                            {t("button_load_more")->str}
                          </button>
                        </div>,
                        ArrayUtils.isEmpty(times),
                      )
                    }}
                  </div>
                | FullyLoaded(submissions) =>
                  <div>
                    {submissionsList(
                      submissions,
                      state,
                      currentUser,
                      getDiscussionSubmissions(send, None),
                    )}
                  </div>
                }}
              </div>
              {switch state.peerSubmissions {
              | Unloaded => React.null
              | _ =>
                let loading = switch state.loading {
                | Reloading(times) => ArrayUtils.isNotEmpty(times)
                | LoadingMore => false
                }
                <LoadingSpinner loading />
              }}
            </div>
          </div>
        : React.null}
    </div>
  </div>
}

let renderPendingStudents = (pendingUserIds, users) =>
  <div className="max-w-3xl mx-auto text-center mt-4">
    <div className="font-semibold text-md"> {t("pending_team_members_notice")->str} </div>
    <div className="flex justify-center flex-wrap">
      {pendingUserIds
      |> Js.Array.map(studentId => {
        let user =
          users |> ArrayUtils.unsafeFind(
            u => u |> User.id == studentId,
            "Unable to find user with id " ++ (studentId ++ "in CoursesCurriculum__Overlay"),
          )

        <div
          key={user |> User.id}
          title={(user |> User.name) ++ " has not completed this target."}
          className="w-10 h-10 rounded-full border border-yellow-400 flex items-center justify-center overflow-hidden mx-1 shadow-md shrink-0 mt-2">
          {user |> User.avatar}
        </div>
      })
      |> React.array}
    </div>
  </div>

let handlePendingStudents = (targetStatus, targetDetails, users) =>
  switch (targetDetails, targetStatus |> TargetStatus.status) {
  | (Some(targetDetails), PendingReview | Completed) =>
    let pendingUserIds = TargetDetails.pendingUserIds(targetDetails)
    pendingUserIds == [] ? React.null : renderPendingStudents(pendingUserIds, users)
  | (Some(_) | None, Locked(_) | Pending | PendingReview | Completed | Rejected) => React.null
  }

let performQuickNavigation = (send, _event) => {
  {
    open // Scroll to the top of the overlay before pushing the new URL.
    Webapi.Dom
    switch document->Document.getElementById("target-overlay") {
    | Some(element) => Webapi.Dom.Element.setScrollTop(element, 0.0)
    | None => ()
    }
  }

  // Clear loaded target details, and select the 'Learn' tab.
  send(PerformQuickNavigation)
}

let navigationLink = (direction, url, send) => {
  let (leftIcon, text, rightIcon) = switch direction {
  | #Previous => (Some("fa-arrow-left"), t("previous_target_button"), None)
  | #Next => (None, t("next_target_button"), Some("fa-arrow-right"))
  }

  let arrow = icon =>
    icon->Belt.Option.mapWithDefault(React.null, icon =>
      <FaIcon classes={"rtl:rotate-180 fas " ++ icon} />
    )

  <Link
    href=url
    onClick={performQuickNavigation(send)}
    className="block p-2 md:p-4 text-center border rounded-lg bg-gray-50 hover:bg-gray-50">
    {arrow(leftIcon)}
    <span className="mx-2 hidden md:inline"> {text |> str} </span>
    {arrow(rightIcon)}
  </Link>
}

let scrollOverlayToTop = _event => {
  let element = {
    open Webapi.Dom
    document->Document.getElementById("target-overlay")
  }
  element->Belt.Option.mapWithDefault((), element => element->Webapi.Dom.Element.setScrollTop(0.0))
}

let quickNavigationLinks = (targetDetails, send) => {
  let (previous, next) = targetDetails |> TargetDetails.navigation

  <div className="pb-6">
    <hr className="my-6" />
    <div className="mx-auto max-w-3xl flex px-3 lg:px-0" id="target-navigation">
      <div className="w-1/3 me-2">
        {previous->Belt.Option.mapWithDefault(React.null, previousUrl =>
          navigationLink(#Previous, previousUrl, send)
        )}
      </div>
      <div className="w-1/3 mx-2">
        <button
          onClick=scrollOverlayToTop
          className="block w-full focus:outline-none p-2 md:p-4 text-center border rounded-lg bg-gray-50 hover:bg-gray-50">
          <span className="mx-2 hidden md:inline"> {t("scroll_to_top")->str} </span>
          <span className="mx-2 md:hidden">
            <i className="fas fa-arrow-up" />
          </span>
        </button>
      </div>
      <div className="w-1/3 ms-2">
        {next->Belt.Option.mapWithDefault(React.null, nextUrl =>
          navigationLink(#Next, nextUrl, send)
        )}
      </div>
    </div>
  </div>
}

let updatePendingUserIdsWhenAddingSubmission = (send, target, addSubmissionCB, submission) => {
  send(AddSubmission(target |> Target.role))
  addSubmissionCB(submission)
}

@react.component
let make = (
  ~target,
  ~course,
  ~targetStatus,
  ~addSubmissionCB,
  ~targets,
  ~targetRead,
  ~markReadCB,
  ~statusOfTargets,
  ~users,
  ~evaluationCriteria,
  ~coaches,
  ~preview,
  ~author,
  ~currentUser,
) => {
  let (state, send) = React.useReducer(reducer, initialState)

  React.useEffect1(loadTargetDetails(target, currentUser, send), [Target.id(target)])

  React.useEffect(() => {
    ScrollLock.activate()
    Some(() => ScrollLock.deactivate())
  })

  <div
    id="target-overlay"
    className="fixed z-50 top-0 start-0 w-full h-full overflow-y-scroll bg-white">
    <div className="bg-gray-50 border-b border-gray-300 px-3">
      <div className="course-overlay__header-container pt-12 lg:pt-0 mx-auto">
        {overlayStatus(course, target, targetStatus, preview)}
        {handleLocked(target, targets, targetStatus, statusOfTargets, send)}
        {handlePendingStudents(targetStatus, state.targetDetails, users)}
        {switch state.targetDetails {
        | Some(targetDetails) => tabOptions(state, send, targetDetails, targetStatus)
        | None =>
          <div className="course-overlay__skeleton-head-container max-w-3xl w-full mx-auto">
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
        }}
      </div>
    </div>
    {switch state.targetDetails {
    | Some(targetDetails) =>
      let completionType = targetDetails |> TargetDetails.computeCompletionType

      <div>
        <div className="mx-auto mt-6 md:mt-8 px-3 lg:px-0">
          <div className="max-w-3xl mx-auto">
            {learnSection(
              send,
              targetDetails,
              targetRead,
              state.tab,
              author,
              Course.id(course),
              Target.id(target),
              markReadCB,
              targetStatus,
              completionType,
              preview,
            )}
          </div>
          <div className="max-w-3xl mx-auto">
            {discussSection(target, targetDetails, state.tab)}
          </div>
          {completeSection(
            state,
            send,
            target,
            targetDetails,
            targetStatus,
            updatePendingUserIdsWhenAddingSubmission(send, target, addSubmissionCB),
            evaluationCriteria,
            coaches,
            users,
            preview,
            completionType,
            currentUser,
          )}
        </div>
        {quickNavigationLinks(targetDetails, send)}
      </div>

    | None =>
      <div className="course-overlay__skeleton-body-container max-w-3xl w-full pb-4 mx-auto">
        <div className="course-overlay__skeleton-body-wrapper mt-8 px-3 lg:px-0">
          <div
            className="course-overlay__skeleton-line-placeholder-md mt-4 w-1/2 skeleton-animate"
          />
          <div className="course-overlay__skeleton-line-placeholder-sm mt-4 skeleton-animate" />
          <div className="course-overlay__skeleton-line-placeholder-sm mt-4 skeleton-animate" />
          <div
            className="course-overlay__skeleton-line-placeholder-sm mt-4 w-3/4 skeleton-animate"
          />
          <div className="course-overlay__skeleton-image-placeholder mt-5 skeleton-animate" />
          <div
            className="course-overlay__skeleton-line-placeholder-sm mt-4 w-2/5 skeleton-animate"
          />
        </div>
        <div className="course-overlay__skeleton-body-wrapper mt-8 px-3 lg:px-0">
          <div
            className="course-overlay__skeleton-line-placeholder-sm mt-4 w-3/4 skeleton-animate"
          />
          <div className="course-overlay__skeleton-line-placeholder-sm mt-4 skeleton-animate" />
          <div
            className="course-overlay__skeleton-line-placeholder-sm mt-4 w-3/4 skeleton-animate"
          />
        </div>
      </div>
    }}
  </div>
}
