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
    className="flex max-w-lg md:mx-auto mx-3 mt-4 rounded-lg px-3 py-2 shadow-lg items-center border border-primary-300 bg-gray-50 ">
    <img className="w-20 md:w-22 flex-no-shrink" src=Notice.previewModeImage />
    <div className="flex-1  ms-4">
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

@react.component
let make = (~notice) =>
  switch notice {
  | Notice.Preview => showPreviewMessage()
  | CourseEnded => courseEndedMessage()
  | CourseComplete => courseCompleteMessage()
  | AccessEnded => accessEndedMessage()
  | Nothing => React.null
  }
