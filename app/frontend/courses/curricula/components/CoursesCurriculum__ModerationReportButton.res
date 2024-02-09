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

  <div>
    {switch showReport {
    | false => React.null
    | true =>
      <div className="blanket grid place-items-center mx-auto">
        <div className="max-w-xl w-full mx-auto p-4 bg-white rounded-lg shadow-lg">
          <div className="flex items-center justify-between">
            <h2 className="font-semibold leading-tight"> {"Report"->str} </h2>
            <button
              onClick={updateShowReport(setShowReport, false)}
              className="w-6 h-6 flex items-center justify-center rounded-md text-gray-700 bg-gray-100 hover:bg-gray-200 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 transition">
              <Icon className="if i-times-light text-xl if-fw" />
              <span className="sr-only"> {"Close"->str} </span>
            </button>
          </div>
          <label className="block text-sm text-gray-600 mt-4">
            {"Please provide a reason for reporting"->str}
          </label>
          <textarea
            className="w-full text-sm p-2 border rounded-md mt-1"
            type_="text"
            value={reportReason}
            placeholder={"Share reason for reporting"}
            onChange={updateReportReason(setReportReason)}
          />
          <div className="mt-3 sm:mt-4 sm:flex">
            <button
              className="btn btn-primary"
              onClick={createModerationReport(
                reportableType,
                reportableId,
                reportReason,
                setModerationReports,
                setShowReport,
                setReportReason,
              )}>
              {"Report"->str}
            </button>
            <button
              onClick={updateShowReport(setShowReport, false)}
              className="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:ml-3 sm:mt-0 sm:w-auto">
              {"Cancel"->str}
            </button>
          </div>
        </div>
      </div>
    }}
    <button
      onClick={updateShowReport(setShowReport, true)}
      disabled={reported}
      className="flex items-center justify-center cursor-pointer p-1 text-sm border rounded-md text-gray-700 bg-gray-100 hover:text-gray-800 hover:bg-gray-50 focus:outline-none focus:text-gray-800 focus:bg-gray-50 whitespace-nowrap">
      {switch reported {
      | true =>
        <span className="flex items-center md:space-x-1">
          <Icon className="if i-eye-closed-light if-fw" />
          <span className="hidden md:inline-block text-xs"> {"Reported"->str} </span>
        </span>
      | false =>
        <span className="flex items-center md:space-x-1">
          <Icon className="if i-eye-light if-fw" />
          <span className="hidden md:inline-block text-xs"> {"Report"->str} </span>
        </span>
      }}
    </button>
  </div>
}
