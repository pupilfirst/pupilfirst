open CoursesReview__Types

let t = I18n.t(~scope="components.CoursesReview__SubmissionReportShow")

let str = React.string

type state = {showReport: bool}

type action = ChangeReportVisibility

let reducer = (state, action) =>
  switch action {
  | ChangeReportVisibility => {showReport: !state.showReport}
  }

let reportStatusIconClasses = report => {
  switch SubmissionReport.status(report) {
  | Queued => "if i-clock-light text-2xl text-gray-600 rounded-full"
  | InProgress => "if animate-spin i-dashed-circle-regular text-2xl text-yellow-500 rounded-full"
  | Success => "if i-check-circle-solid text-2xl text-green-500 bg-white rounded-full"
  | Failure => "if i-times-circle-solid text-2xl text-red-500 bg-white rounded-full"
  | Error => "if i-exclamation-triangle-circle-solid text-2xl text-gray-600 bg-white rounded-full"
  }
}

let reportStatusString = report => {
  switch SubmissionReport.heading(report) {
  | Some(heading) => heading
  | None =>
    switch SubmissionReport.status(report) {
    | Queued => t("report_status_string.queued")
    | InProgress => t("report_status_string.in_progress")
    | Success => t("report_status_string.success")
    | Failure => t("report_status_string.failure")
    | Error => t("report_status_string.error")
    }
  }
}

let reportConclusionTimeString = report => {
  switch SubmissionReport.status(report) {
  | Queued =>
    "Queued " ++
    DateFns.formatDistanceToNowStrict(SubmissionReport.queuedAt(report), ~addSuffix=true, ())
  | InProgress =>
    "Started " ++
    Belt.Option.mapWithDefault(SubmissionReport.startedAt(report), "", t =>
      DateFns.formatDistanceToNowStrict(t, ~addSuffix=true, ())
    )

  | Error | Failure | Success =>
    "Finished " ++
    Belt.Option.mapWithDefault(SubmissionReport.completedAt(report), "", t =>
      DateFns.formatDistanceToNowStrict(t, ~addSuffix=true, ())
    ) ++
    switch (SubmissionReport.startedAt(report), SubmissionReport.completedAt(report)) {
    | (Some(startedAt), Some(completedAt)) =>
      ", and took " ++ DateFns.formatDistance(completedAt, startedAt, ~includeSeconds=true, ())
    | (_, _) => ""
    }
  }
}

@react.component
let make = (~report) => {
  let (state, send) = React.useReducer(reducer, {showReport: false})
  <div className="px-4 py-1 md:py-2">
    <div className="bg-gray-100 p-2 md:p-4 rounded-md">
      <div className="flex items-center justify-between text-sm">
        <div className="flex items-start gap-3">
          <div className="pt-1"> <Icon className={reportStatusIconClasses(report)} /> </div>
          <div>
            <div className="text-xs">
              {switch SubmissionReport.targetUrl(report) {
              | Some(url) =>
                <a
                  className="text-primary-500 underline font-medium hover:text-primary-600"
                  href={url}
                  target="_blank">
                  {SubmissionReport.reporter(report)->str}
                  <FaIcon classes="if i-external-link-regular ms-1" />
                </a>
              | None => SubmissionReport.reporter(report)->str
              }}
            </div>
            <p className="font-semibold"> {str(reportStatusString(report))} </p>
            <p className="text-gray-600 text-xs mt-1">
              {str(reportConclusionTimeString(report))}
            </p>
          </div>
        </div>
        {ReactUtils.nullIf(
          <button
            onClick={_ => send(ChangeReportVisibility)}
            className="inline-flex items-center text-xs text-gray-800 px-2 py-2 rounded font-semibold hover:bg-gray-300 focus:bg-gray-300 focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500 transition">
            <span className="hidden md:block pe-3 ">
              {str(state.showReport ? t("hide_report_button") : t("show_report_button"))}
            </span>
            {
              let toggleTestReportIcon = state.showReport
                ? "i-arrows-collapse-light"
                : "i-arrows-expand-light"
              <span className="inline-block w-5 h-5">
                <Icon className={"if text-xl " ++ toggleTestReportIcon} />
              </span>
            }
          </button>,
          SubmissionReport.report(report)->Belt.Option.isNone,
        )}
      </div>
      {switch (state.showReport, SubmissionReport.report(report)) {
      | (true, Some(testReport)) =>
        state.showReport
          ? <div>
              <p className="text-sm font-semibold mt-4"> {str(t("test_report"))} </p>
              <div className="bg-white p-3 rounded-md border mt-1">
                <MarkdownBlock profile=Markdown.Permissive markdown={testReport} />
              </div>
            </div>
          : React.null
      | (true, None) | (false, Some(_) | None) => React.null
      }}
    </div>
  </div>
}
