%bs.raw(`require("./CoursesReview__SubmissionInfoCard.css")`)

let t = I18n.t(~scope="components.CoursesReview__SubmissionInfoCard")

open CoursesReview__Types
let str = React.string

let cardClasses = (submission, selected) =>
  "inline-block bg-white relative rounded-lg submission-info__tab flex-shrink-0 focus:ring-2 focus:ring-offset-2 focus:ring-indigo-400 " ++
  (selected
    ? "border border-primary-400 "
    : "bg-opacity-50 border border-gray-300 hover:bg-opacity-100 ") ++
  switch (SubmissionMeta.passedAt(submission), SubmissionMeta.evaluatedAt(submission)) {
  | (None, None) => "submission-info__tab-pending"
  | (None, Some(_)) => "submission-info__tab-rejected"
  | (Some(_), None)
  | (Some(_), Some(_)) => "submission-info__tab-completed"
  }

let showSubmissionStatus = submission => {
  let (text, classes) = switch (
    SubmissionMeta.passedAt(submission),
    SubmissionMeta.evaluatedAt(submission),
  ) {
  | (None, None) => ("Pending Review", "bg-orange-100 text-orange-800 ")
  | (None, Some(_)) => ("Rejected", "bg-red-100 text-red-700")
  | (Some(_), None)
  | (Some(_), Some(_)) => ("Completed", "bg-green-100 text-green-800")
  }
  <div className={"font-semibold px-3 py-px rounded " ++ classes}>
    <span className="hidden md:block"> {text->str} </span>
    <span className="md:hidden block">
      <PfIcon className="if i-check-square-alt-solid if-fw" />
    </span>
  </div>
}

let linkUrl = (submissionId, filterString) => {
  `/submissions/${submissionId}/review${String.trim(filterString) == "" ? "" : "?" ++ filterString}`
}

@react.component
let make = (~submission, ~submissionNumber, ~selected, ~filterString) =>
  <Link
    title={t("submission_hash") ++ string_of_int(submissionNumber)}
    href={linkUrl(SubmissionMeta.id(submission), filterString)}
    key={SubmissionMeta.id(submission)}
    className={cardClasses(submission, selected)}>
    <div className="shadow hover:shadow-lg rounded-lg transition">
      <div className="px-4 py-2 flex flex-row items-center justify-between min-w-min">
        <div className="flex flex-col md:pr-6">
          <h2 className="font-semibold text-sm leading-tight">
            <p className="hidden md:block">
              {(t("submission_hash") ++ string_of_int(submissionNumber))->str}
            </p>
            <p className="md:hidden"> {("#" ++ string_of_int(submissionNumber))->str} </p>
          </h2>
          <span className="text-xs text-gray-800 pt-px whitespace-nowrap">
            {submission->SubmissionMeta.createdAt->DateFns.formatPreset(~year=true, ())->str}
          </span>
        </div>
        <div className="hidden md:flex items-center space-x-2 text-xs w-auto">
          {ReactUtils.nullUnless(
            <div
              className="flex items-center justify-center bg-primary-100 text-primary-600 border border-transparent font-semibold p-1 rounded">
              <PfIcon className="if i-comment-alt-regular if-fw" />
            </div>,
            SubmissionMeta.feedbackSent(submission),
          )}
          {showSubmissionStatus(submission)}
        </div>
      </div>
    </div>
  </Link>
