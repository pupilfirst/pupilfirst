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
    acc || report->ModerationReport.userId === currentUser->User.id
  )

  <div>
    {switch showReport {
    | false => React.null
    | true =>
      <div className="blanket mx-auto grid place-items-center">
        <div className="max-w-xl mx-auto p-4 bg-white rounded-lg shadow-lg">
          <h2> {"Report"->str} </h2>
          <p> {"Please provide a reason for reporting"->str} </p>
          <input
            type_="text"
            value={reportReason}
            placeholder={"Share reason for reporting"}
            onChange={updateReportReason(setReportReason)}
          />
          <button
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
