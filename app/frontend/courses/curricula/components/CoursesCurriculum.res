%%raw(`import "./CoursesCurriculum.css"`)

@module("../images/level-lock.svg") external levelLockedImage: string = "default"
@module("../images/level-empty.svg") external levelEmptyImage: string = "default"

open CoursesCurriculum__Types

let str = React.string
let t = I18n.t(~scope="components.CoursesCurriculum")
let ts = I18n.t(~scope="shared")

type state = {
  selectedLevelId: string,
  showLevelZero: bool,
  latestSubmissions: array<LatestSubmission.t>,
  statusOfTargets: array<TargetStatus.t>,
  targetsRead: array<string>,
  notice: Notice.t,
}

let targetStatusClasses = targetStatus => {
  let statusClasses =
    "curriculum__target-status--" ++ (targetStatus |> TargetStatus.statusClassesSufix)
  "curriculum__target-status px-1 md:px-3 py-px ms-4 h-6 " ++ statusClasses
}

let rendertarget = (target, statusOfTargets, targetsRead, author, courseId) => {
  let targetId = target |> Target.id
  let targetStatus =
    statusOfTargets |> ArrayUtils.unsafeFind(
      ts => ts |> TargetStatus.targetId == targetId,
      "Could not find targetStatus for listed target with ID " ++ targetId,
    )
  let targetRead = Js.Array.includes(targetId, targetsRead)

  <div
    key={"target-" ++ targetId}
    className="courses-curriculum__target-container flex border-t bg-white hover:bg-gray-50">
    <Link
      props={"data-target-id": targetId}
      href={"/targets/" ++ targetId}
      className={"p-3 md:p-6 flex flex-1 items-start justify-between hover:text-primary-500 cursor-pointer focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500 focus:text-primary-500 focus:bg-gray-50 focus:rounded-lg"}
      ariaLabel={"Select Target: " ++
      (Target.title(target) ++
      ", Status: " ++
      TargetStatus.statusToString(targetStatus))}>
      <span className="inline-flex items-center space-x-3">
        {targetRead
          ? <span title="Marked read" className="w-5 h-5 flex items-center justify-center">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                fill="currentColor"
                className="w-4 h-4 text-gray-500"
                viewBox="0 0 16 16">
                <path
                  d="M12.354 4.354a.5.5 0 0 0-.708-.708L5 10.293 1.854 7.146a.5.5 0 1 0-.708.708l3.5 3.5a.5.5 0 0 0 .708 0l7-7zm-4.208 7-.896-.897.707-.707.543.543 6.646-6.647a.5.5 0 0 1 .708.708l-7 7a.5.5 0 0 1-.708 0z"
                />
                <path d="m5.354 7.146.896.897-.707.707-.897-.896a.5.5 0 1 1 .708-.708z" />
              </svg>
            </span>
          : <span title="Not read yet" className="w-5 h-5 flex items-center justify-center">
              <span className="w-2 h-2 inline-block rounded-full bg-blue-600" />
            </span>}
        <span className="text-sm md:text-base font-medium"> {Target.title(target)->str} </span>
      </span>
      <div className="flex">
        {Target.milestone(target)
          ? <div
              className="flex items-center flex-shrink-0 text-xs font-medium border border-yellow-200 bg-yellow-100 text-yellow-800 ms-3 px-1.5 md:px-2 py-1 rounded-md">
              <Icon className="if i-milestone-solid text-sm" />
              <span className="hidden md:block ms-1"> {ts("milestone_label")->str} </span>
            </div>
          : React.null}
        {ReactUtils.nullIf(
          <span className={targetStatusClasses(targetStatus)}>
            {TargetStatus.statusToString(targetStatus)->str}
          </span>,
          TargetStatus.isAccessEnded(targetStatus) || TargetStatus.isPending(targetStatus),
        )}
      </div>
    </Link>
    {ReactUtils.nullUnless(
      <a
        title={t("edit_target_button_title", ~variables=[("title", Target.title(target))])}
        ariaLabel={t("edit_target_button_title", ~variables=[("title", Target.title(target))])}
        href={"/school/courses/" ++ courseId ++ "/targets/" ++ targetId ++ "/content"}
        className="hidden lg:block courses-curriculum__target-quick-link text-gray-400 border-s border-transparent py-6 px-3 hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500 focus:bg-gray-50 focus:text-primary-500 focus:rounded-lg">
        <i className="fas fa-pencil-alt" />
      </a>,
      author,
    )}
  </div>
}

let renderTargetGroup = (targetGroup, targets, statusOfTargets, targetsRead, author, courseId) => {
  let targetGroupId = targetGroup |> TargetGroup.id
  let targets = targets |> Js.Array.filter(t => t |> Target.targetGroupId == targetGroupId)

  <div
    key={"target-group-" ++ targetGroupId}
    className="curriculum__target-group-container relative mt-5 px-3">
    <div
      className="curriculum__target-group max-w-3xl md:max-w-4xl 2xl:max-w-5xl mx-auto bg-white rounded-lg shadow-md relative overflow-hidden ">
      <div className="p-3 md:p-6 pt-5 text-center">
        <div className="text-2xl font-bold leading-snug">
          {TargetGroup.name(targetGroup)->str}
        </div>
        <MarkdownBlock
          className="text-sm max-w-md mx-auto leading-snug"
          markdown={TargetGroup.description(targetGroup)}
          profile=Markdown.AreaOfText
        />
      </div>
      {targets
      |> ArrayUtils.copyAndSort((t1, t2) => (t1 |> Target.sortIndex) - (t2 |> Target.sortIndex))
      |> Js.Array.map(target =>
        rendertarget(target, statusOfTargets, targetsRead, author, courseId)
      )
      |> React.array}
    </div>
  </div>
}

let addSubmission = (setState, latestSubmission) =>
  setState(state => {
    let withoutSubmissionForThisTarget =
      state.latestSubmissions |> Js.Array.filter(s =>
        s |> LatestSubmission.targetId != (latestSubmission |> LatestSubmission.targetId)
      )

    {
      ...state,
      latestSubmissions: Js.Array.concat([latestSubmission], withoutSubmissionForThisTarget),
    }
  })

let addMarkRead = (setState, markedReadTargetId) =>
  setState(state => {
    {
      ...state,
      targetsRead: Js.Array.concat([markedReadTargetId], state.targetsRead),
    }
  })

let handleLockedLevel = level =>
  <div className="max-w-xl mx-auto text-center mt-4">
    <div className="text-2xl font-bold px-3"> {t("level_locked") |> str} </div>
    <img className="max-w-sm mx-auto" src=levelLockedImage />
    {switch level |> Level.unlockAt {
    | Some(date) =>
      let dateString = date->DateFns.format("MMMM d, yyyy")
      <div className="font-semibold text-md px-3">
        <p> {t("level_locked_notice")->str} </p>
        <p> {t("level_locked_explanation", ~variables=[("date", dateString)])->str} </p>
      </div>
    | None => React.null
    }}
  </div>

let issuedCertificate = course =>
  switch Course.certificateSerialNumber(course) {
  | Some(csn) =>
    <div
      className="max-w-3xl md:max-w-4xl 2xl:max-w-5xl mx-auto text-center mt-4 bg-white lg:rounded-lg shadow-md px-6 pt-6 pb-8">
      <div className="font-semibold text-xl mx-auto mt-2 leading-tight">
        {t("issued_certificate_heading")->str}
      </div>
      <a href={"/c/" ++ csn} className="mt-4 mb-2 btn btn-primary">
        <FaIcon classes="fas fa-certificate" />
        <span className="ms-2"> {t("issued_certificate_button")->str} </span>
      </a>
    </div>
  | None => React.null
  }

let computeNotice = (course, student, preview) =>
  if preview {
    Notice.Preview
  } else if Course.ended(course) {
    CourseEnded
  } else if Student.accessEnded(student) {
    AccessEnded
  } else if Belt.Option.isSome(Student.completedAt(student)) {
    CourseComplete
  } else {
    Nothing
  }

let navigationLink = (direction, level, setState) => {
  let (leftIcon, ariaLabel, longText, shortText, rightIcon) = switch direction {
  | #Previous => (
      Some("fa-arrow-left rtl:rotate-180"),
      t("nav_aria_previous_level"),
      t("nav_long_previous_level"),
      t("nav_short_previous_level"),
      None,
    )
  | #Next => (
      None,
      t("nav_aria_next_level"),
      t("nav_long_next_level"),
      t("nav_short_next_level"),
      Some("fa-arrow-right rtl:rotate-180"),
    )
  }

  let arrow = icon =>
    icon->Belt.Option.mapWithDefault(React.null, icon => <FaIcon classes={"fas " ++ icon} />)

  <button
    ariaLabel
    onClick={_ => setState(state => {...state, selectedLevelId: Level.id(level)})}
    className="block w-full focus:outline-none p-4 text-center border rounded-lg bg-gray-100 hover:bg-primary-50 cursor-pointer hover:text-primary-500 focus:text-primary-500 focus:bg-gray-50 focus:ring-2 focus:ring-inset focus:ring-focusColor-500">
    {arrow(leftIcon)}
    <span className="mx-2 hidden md:inline"> {longText->str} </span>
    <span className="mx-2 inline md:hidden"> {shortText->str} </span>
    {arrow(rightIcon)}
  </button>
}

let quickNavigationLinks = (levels, selectedLevel, setState) => {
  let previous = selectedLevel |> Level.previous(levels)
  let next = selectedLevel |> Level.next(levels)

  <div key="quick-navigation-links">
    <hr className="my-6" />
    <div className="container mx-auto max-w-3xl flex px-3 lg:px-0">
      {switch (previous, next) {
      | (Some(previousLevel), Some(nextLevel)) =>
        [
          <div key="previous" className="w-1/2 me-2">
            {navigationLink(#Previous, previousLevel, setState)}
          </div>,
          <div key="next" className="w-1/2 ms-2">
            {navigationLink(#Next, nextLevel, setState)}
          </div>,
        ] |> React.array

      | (Some(previousUrl), None) =>
        <div className="w-full"> {navigationLink(#Previous, previousUrl, setState)} </div>
      | (None, Some(nextUrl)) =>
        <div className="w-full"> {navigationLink(#Next, nextUrl, setState)} </div>
      | (None, None) => React.null
      }}
    </div>
  </div>
}

@react.component
let make = (
  ~currentUser,
  ~author,
  ~course,
  ~levels,
  ~targetGroups,
  ~targets,
  ~submissions,
  ~student,
  ~coaches,
  ~users,
  ~evaluationCriteria,
  ~preview,
  ~accessLockedLevels,
  ~targetsRead,
) => {
  let url = RescriptReactRouter.useUrl()

  let selectedTarget = switch url.path {
  | list{"targets", targetId, ..._} =>
    targetId
    ->StringUtils.paramToId
    ->Belt.Option.map(targetId =>
      targets |> ArrayUtils.unsafeFind(
        t => t |> Target.id == targetId,
        "Could not find selectedTarget with ID " ++ targetId,
      )
    )
  | _ => None
  }

  /* Level selection is a bit complicated because of how the selector for L0 is
   * separate from the other levels. selectedLevelId is the numbered level
   * selected by the user, whereas showLevelZero is the toggle on the title of
   * L0 determining whether the user has picked it or not - it'll show up only
   * if L0 is available, and will override the selectedLevelId. This rule is
   * used to determine currentLevelId, which is the actual level whose contents
   * are shown on the page. */

  let levelZero = levels |> Js.Array.find(l => l |> Level.number == 0)
  let studentLevelId = student |> Student.levelId

  let targetLevelId = switch selectedTarget {
  | Some(target) =>
    let targetGroupId = target |> Target.targetGroupId

    let targetGroup =
      targetGroups |> ArrayUtils.unsafeFind(
        t => t |> TargetGroup.id == targetGroupId,
        "Could not find targetGroup with ID " ++ targetGroupId,
      )

    Some(targetGroup |> TargetGroup.levelId)
  | None => None
  }

  /* Curried function so that this can be re-used when a new submission is created. */
  let computeTargetStatus = TargetStatus.compute(
    preview,
    student,
    course,
    levels,
    targetGroups,
    targets,
  )

  let initialRender = React.useRef(true)

  let (state, setState) = React.useState(() => {
    let statusOfTargets = computeTargetStatus(targetsRead, submissions)
    {
      selectedLevelId: switch (preview, targetLevelId, levelZero) {
      | (true, None, _levelZero) => Level.first(levels)->Level.id
      | (_, Some(targetLevelId), Some(levelZero)) =>
        levelZero |> Level.id == targetLevelId ? studentLevelId : targetLevelId
      | (_, Some(targetLevelId), None) => targetLevelId
      | (_, None, _) => studentLevelId
      },
      showLevelZero: switch (levelZero, targetLevelId) {
      | (Some(levelZero), Some(targetLevelId)) => levelZero |> Level.id == targetLevelId
      | (Some(_), None)
      | (None, Some(_))
      | (None, None) => false
      },
      latestSubmissions: submissions,
      statusOfTargets,
      notice: computeNotice(course, student, preview),
      targetsRead,
    }
  })

  let currentLevelId = switch (levelZero, state.showLevelZero) {
  | (Some(levelZero), true) => levelZero |> Level.id
  | (Some(_), false)
  | (None, true | false) =>
    state.selectedLevelId
  }

  let currentLevel =
    levels |> ArrayUtils.unsafeFind(
      l => l |> Level.id == currentLevelId,
      "Could not find currentLevel with id " ++ currentLevelId,
    )

  let selectedLevel =
    levels |> ArrayUtils.unsafeFind(
      l => l |> Level.id == state.selectedLevelId,
      "Could not find selectedLevel with id " ++ state.selectedLevelId,
    )

  React.useEffect2(() => {
    if initialRender.current {
      initialRender.current = false
    } else {
      let newStatusOfTargets = computeTargetStatus(state.targetsRead, state.latestSubmissions)

      setState(state => {
        ...state,
        statusOfTargets: newStatusOfTargets,
        notice: computeNotice(course, student, preview),
      })
    }
    None
  }, (state.latestSubmissions, state.targetsRead))

  let targetGroupsInLevel =
    targetGroups |> Js.Array.filter(tg => tg |> TargetGroup.levelId == currentLevelId)

  <div
    role="main"
    ariaLabel="Curriculum"
    className="md:h-screen bg-gray-50 md:pt-18 pb-20 md:pb-8 overflow-y-auto">
    {switch selectedTarget {
    | Some(target) =>
      let targetStatus =
        state.statusOfTargets |> ArrayUtils.unsafeFind(
          ts => ts |> TargetStatus.targetId == (target |> Target.id),
          "Could not find targetStatus for selectedTarget with ID " ++ (target |> Target.id),
        )
      let targetRead = Js.Array.includes(target->Target.id, state.targetsRead)
      <CoursesCurriculum__Overlay
        target
        course
        targetStatus
        addSubmissionCB={addSubmission(setState)}
        targets
        targetRead
        markReadCB={addMarkRead(setState)}
        statusOfTargets=state.statusOfTargets
        users
        evaluationCriteria
        coaches
        preview
        author
        currentUser
      />

    | None => React.null
    }}
    {issuedCertificate(course)}
    <CoursesCurriculum__NoticeManager notice=state.notice />
    {[
      <div className="relative" key="curriculum-body">
        <CoursesCurriculum__LevelSelector
          levels
          selectedLevel
          preview
          setSelectedLevelId={selectedLevelId => setState(state => {...state, selectedLevelId})}
          showLevelZero=state.showLevelZero
          setShowLevelZero={showLevelZero => setState(state => {...state, showLevelZero})}
          levelZero
        />
        {ReactUtils.nullUnless(
          <div className="text-center mt-2 max-w-3xl mx-auto">
            <a
              className="btn btn-primary-ghost btn-small"
              href={"/school/courses/" ++
              Course.id(course) ++
              "/curriculum?level=" ++
              Level.number(currentLevel)->string_of_int}>
              <i className="fas fa-pencil-alt" />
              <span className="ms-2"> {t("edit_level_button")->str} </span>
            </a>
          </div>,
          author,
        )}
        {currentLevel |> Level.isLocked && accessLockedLevels
          ? <div
              className="text-center p-3 mt-5 border rounded-lg bg-blue-100 max-w-3xl mx-auto"
              dangerouslySetInnerHTML={
                "__html": t(
                  "level_locked_for_students_notice",
                  ~variables=[("date", Level.unlockDateString(currentLevel))],
                ),
              }
            />
          : React.null}
        {Level.isUnlocked(currentLevel) || accessLockedLevels
          ? targetGroupsInLevel == []
              ? <div className="mx-auto py-10">
                  <img className="max-w-xs md:max-w-sm mx-auto" src=levelEmptyImage />
                  <p className="text-center font-semibold text-lg mt-4">
                    {t("empty_level_content_notice") |> str}
                  </p>
                </div>
              : targetGroupsInLevel
                |> TargetGroup.sort
                |> Js.Array.map(targetGroup =>
                  renderTargetGroup(
                    targetGroup,
                    targets,
                    state.statusOfTargets,
                    state.targetsRead,
                    author,
                    Course.id(course),
                  )
                )
                |> React.array
          : handleLockedLevel(currentLevel)}
      </div>,
      {state.showLevelZero ? React.null : quickNavigationLinks(levels, selectedLevel, setState)},
    ] |> React.array}
  </div>
}
