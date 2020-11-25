open CoursesCurriculum__Types

let str = React.string
let t = I18n.t(~scope="components.CoursesCurriculum__NoticeManager")

let showNotice = (
  ~title,
  ~description,
  ~notice,
  ~classes="max-w-3xl mx-auto text-center mt-4 bg-white lg:rounded-lg shadow-md px-6 pt-6 pb-8",
  (),
) =>
  <div className=classes>
    <img className="h-50 mx-auto" src={notice |> Notice.icon} />
    <div className="max-w-xl font-bold text-xl mx-auto mt-2 leading-tight"> {title |> str} </div>
    <div className="text-sm max-w-lg mx-auto mt-2"> {description |> str} </div>
  </div>

let courseCompleteMessage = () =>
  showNotice(
    ~title=t("course_complete_title"),
    ~description=t("course_complete_description"),
    ~notice=Notice.CourseComplete,
    (),
  )

let courseEndedMessage = () =>
  showNotice(
    ~title=t("course_ended_title"),
    ~description=t("course_ended_description"),
    ~notice=Notice.CourseEnded,
    (),
  )

let showPreviewMessage = () =>
  <div
    className="flex max-w-lg md:mx-auto mx-3 mt-4 rounded-lg px-3 py-2 shadow-lg items-center border border-primary-300 bg-gray-200 ">
    <img className="w-20 md:w-22 flex-no-shrink" src=Notice.previewModeImage />
    <div className="flex-1 text-left ml-4">
      <h4 className="font-bold text-lg leading-tight"> {t("preview_mode_title")->str} </h4>
      <p className="text-sm mt-1"> {t("preview_mode_description")->str} </p>
    </div>
  </div>

let accessEndedMessage = () =>
  showNotice(
    ~title=t("access_ended_title"),
    ~description=t("access_ended_description"),
    ~notice=Notice.AccessEnded,
    (),
  )

let teamMembersPendingMessage = () =>
  showNotice(
    ~title=t("team_members_pending_title"),
    ~description=t("team_members_pending_description"),
    ~notice=Notice.TeamMembersPending,
    (),
  )

let levelUpBlockedMessage = (currentLevelNumber, someSubmissionsRejected) => {
  let titleKey = someSubmissionsRejected
    ? "level_up_blocked.title_rejected"
    : "level_up_blocked.title_pending_review"

  let prefix = t(
    ~variables=[("number", string_of_int(currentLevelNumber))],
    "level_up_blocked.body_prefix",
  )

  let body = t(
    someSubmissionsRejected
      ? "level_up_blocked.body_middle_rejected"
      : "level_up_blocked.body_middle_pending_review",
  )

  let suffix = t("level_up_blocked.body_suffix")

  showNotice(
    ~title=t(titleKey),
    ~description=prefix ++ (body ++ suffix),
    ~notice=Notice.LevelUpBlocked(currentLevelNumber, someSubmissionsRejected),
    (),
  )
}

let levelUpLimitedMessage = (currentLevelNumber, minimumRequiredLevelNumber) => {
  let description = t(
    ~variables=[
      ("currentLevel", string_of_int(currentLevelNumber)),
      ("minimumRequiredLevel", string_of_int(minimumRequiredLevelNumber)),
    ],
    "level_up_limited_description",
  )

  showNotice(
    ~title=t("level_up_limited_title"),
    ~description,
    ~notice=Notice.LevelUpLimited(currentLevelNumber, minimumRequiredLevelNumber),
    (),
  )
}

let renderLevelUp = course =>
  <div
    className="max-w-3xl mx-3 lg:mx-auto text-center mt-4 bg-white rounded-lg shadow px-6 pt-4 pb-8">
    {showNotice(
      ~title=t("level_up_title"),
      ~description=t("level_up_description"),
      ~notice=Notice.LevelUp,
      ~classes="",
      (),
    )}
    <CoursesCurriculum__LevelUpButton course />
  </div>

@react.component
let make = (~notice, ~course) =>
  switch notice {
  | Notice.Preview => showPreviewMessage()
  | CourseEnded => courseEndedMessage()
  | CourseComplete => courseCompleteMessage()
  | AccessEnded => accessEndedMessage()
  | LevelUp => renderLevelUp(course)
  | LevelUpLimited(currentLevelNumber, minimumRequiredLevelNumber) =>
    levelUpLimitedMessage(currentLevelNumber, minimumRequiredLevelNumber)
  | LevelUpBlocked(currentLevelNumber, someSubmissionsRejected) =>
    levelUpBlockedMessage(currentLevelNumber, someSubmissionsRejected)
  | TeamMembersPending => teamMembersPendingMessage()
  | Nothing => React.null
  }
