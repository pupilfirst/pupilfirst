let str = React.string
let tr = I18n.t(~scope="components.CoursesCurriculum__ModerationReportButton")

open CoursesCurriculum__Types

module CreateModerationReportMutation = %graphql(`
   mutation CreateModerationReportMutation($reason: String!, $reportableId: String!, $reportableType: String! ) {
     createModerationReport(reason: $reason, reportableId: $reportableId, reportableType: $reportableType ) {
       moderationReport {
         id
         reason
         reportableId
         reportableType
         userId
       }
     }
   }
   `)

let createModerationReport = (
  reportableType,
  reportableId,
  reason,
  setModerationReports,
  setShowReport,
  setReportReason,
  event,
) => {
  ReactEvent.Mouse.preventDefault(event)
  CreateModerationReportMutation.make({
    reason,
    reportableId,
    reportableType,
  })
  |> Js.Promise.then_(response => {
    switch response["createModerationReport"]["moderationReport"] {
    | Some(moderationReport) =>
      setModerationReports(moderationReports =>
        Js.Array2.concat([moderationReport], moderationReports)
      )
      setShowReport(_ => false)
      setReportReason(_ => "")
    | None => ()
    }
    Js.Promise.resolve()
  })
  |> ignore
}

let updateReportReason = (setReportReason, event) => {
  ReactEvent.Form.preventDefault(event)
  setReportReason(ReactEvent.Form.currentTarget(event)["value"])
}

let updateShowReport = (setShowReport, showReport, event) => {
  ReactEvent.Mouse.preventDefault(event)
  setShowReport(_ => showReport)
}

@react.component
let make = (~currentUser, ~moderationReports, ~reportableId, ~reportableType) => {
  let (moderationReports, setModerationReports) = React.useState(() => moderationReports)
  let (showReport, setShowReport) = React.useState(() => false)
  let (reportReason, setReportReason) = React.useState(() => "")

  let reported = Belt.Array.reduce(moderationReports, false, (acc, report) =>
    acc || report->ModerationReport.userId === currentUser->CurrentUser.id
  )

  <div className="relative">
    {showReport
      ? <dialog
          role="dialog"
          className="fixed inset-0 z-[999] grid place-items-center w-full h-full bg-gray-950/75 dark:bg-gray-50/75 backdrop-blur-sm ease-in duration-300">
          <div className="max-w-xl w-full mx-auto p-4 bg-white rounded-lg shadow-lg">
            <div className="flex items-center justify-between">
              <h2 className="font-semibold leading-tight text-gray-900"> {tr("report")->str} </h2>
              <button
                onClick={updateShowReport(setShowReport, false)}
                className="w-6 h-6 flex items-center justify-center rounded-md text-gray-700 bg-gray-100 hover:bg-gray-200 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-focusColor-500 focus:ring-offset-2 transition">
                <Icon className="if i-times-light text-xl if-fw" />
                <span className="sr-only"> {tr("close")->str} </span>
              </button>
            </div>
            <textarea
              id={"report_reason-" ++ reportableId}
              className="w-full text-sm text-gray-900 p-2 border rounded-md mt-4"
              type_="text"
              autoFocus={true}
              value={reportReason}
              placeholder={tr("share_reason")}
              onChange={updateReportReason(setReportReason)}
            />
            <div className="mt-3 sm:mt-4 sm:flex">
              <button
                disabled={reportReason == ""}
                className="btn btn-primary"
                onClick={createModerationReport(
                  reportableType,
                  reportableId,
                  reportReason,
                  setModerationReports,
                  setShowReport,
                  setReportReason,
                )}>
                {tr("report")->str}
              </button>
              <button
                onClick={updateShowReport(setShowReport, false)}
                className="mt-3 inline-flex w-full justify-center rounded bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:ml-3 sm:mt-0 sm:w-auto focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-focusColor-500">
                {tr("cancel")->str}
              </button>
            </div>
          </div>
        </dialog>
      : React.null}
    {reported
      ? <div
          className="flex items-center justify-center p-1 text-sm text-red-600 whitespace-nowrap">
          <span className="flex items-center md:space-x-1">
            <Icon className="if i-flag-light if-fw" />
            <span className="hidden md:inline-block text-xs"> {tr("reported")->str} </span>
          </span>
        </div>
      : <button
          onClick={updateShowReport(setShowReport, true)}
          disabled={reported}
          className="curriculum-moderation__report-button md:hidden md:group-hover:flex md:group-focus-within:flex items-center justify-center cursor-pointer p-1 text-sm border rounded-md text-gray-700 bg-gray-100 hover:text-gray-800 hover:bg-gray-50 whitespace-nowrap focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-focusColor-500 transition">
          <span className="flex items-center md:space-x-1">
            <Icon className="if i-flag-light if-fw" />
            <span className="hidden md:inline-block text-xs"> {tr("report")->str} </span>
          </span>
        </button>}
  </div>
}
