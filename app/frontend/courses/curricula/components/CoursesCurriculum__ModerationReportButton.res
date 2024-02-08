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
      <div className="blanket">
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
    }}
    <button
      onClick={updateShowReport(setShowReport, true)}
      disabled={reported}
      className="cursor-pointer block p-3 text-sm font-semibold text-gray-900 border-b border-gray-50 bg-white hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:text-primary-500 focus:bg-gray-50 whitespace-nowrap">
      // <i className=icon />

      <span className="font-semibold ms-2">
        {switch reported {
        | true => "Reported"->str
        | false => "Report"->str
        }}
      </span>
    </button>
  </div>
}
