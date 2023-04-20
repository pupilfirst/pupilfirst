%%raw(`import "./CoursesReview__SubmissionInfoCard.css"`)

let t = I18n.t(~scope="components.CoursesReview__SubmissionInfoCard")

open CoursesReview__Types
let str = React.string

let cardClasses = (submission, selected) =>
  "inline-block bg-white relative submission-info__tab shrink-0 rounded-lg transition " ++
  (selected
    ? "border border-primary-400 "
    : "bg-white/50 border border-gray-300 hover:bg-white ") ++
  switch (
    SubmissionMeta.archivedAt(submission),
    SubmissionMeta.passedAt(submission),
    SubmissionMeta.evaluatedAt(submission),
  ) {
  | (Some(_), _, _) => "submission-info__tab-deleted cursor-not-allowed focus:outline-none"
  | (
      None,
      None,
      None,
    ) => "submission-info__tab-pending focus:ring focus:ring-focusColor-400 shadow hover:shadow-lg"
  | (
      None,
      None,
      Some(_),
    ) => "submission-info__tab-rejected focus:ring focus:ring-focusColor-400 shadow hover:shadow-lg"
  | (None, Some(_), None)
  | (
    None,
    Some(_),
    Some(_),
  ) => "submission-info__tab-completed focus:ring focus:ring-focusColor-400 shadow hover:shadow-lg"
  }

let showSubmissionStatus = submission => {
  let (text, classes) = switch (
    SubmissionMeta.archivedAt(submission),
    SubmissionMeta.passedAt(submission),
    SubmissionMeta.evaluatedAt(submission),
  ) {
  | (Some(_), _, _) => (t("deleted"), "bg-gray-300 text-gray-800 ")
  | (None, None, None) => (t("pending_review"), "bg-orange-100 text-orange-800 ")
  | (None, None, Some(_)) => (t("rejected"), "bg-red-100 text-red-700")
  | (None, Some(_), None)
  | (None, Some(_), Some(_)) => (t("completed"), "bg-green-100 text-green-800")
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

let submissionInfoCardContent = (submission, submissionNumber) => {
  <div className="px-4 py-2 flex flex-row items-center justify-between min-w-min">
    <div className="flex flex-col md:pe-6">
      <h2 className="font-semibold text-sm leading-tight">
        <p className="hidden md:block">
          {(t("submission_hash") ++ " #" ++ string_of_int(submissionNumber))->str}
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
}

@react.component
let make = (~submission, ~submissionNumber, ~selected, ~filterString) => {
  switch SubmissionMeta.archivedAt(submission) {
  | Some(_archivedAt) =>
    <div
      title={t("submission_hash") ++ " #" ++ string_of_int(submissionNumber)}
      key={SubmissionMeta.id(submission)}
      className={cardClasses(submission, selected)}>
      {submissionInfoCardContent(submission, submissionNumber)}
    </div>
  | None =>
    <Link
      title={t("submission_hash") ++ " #" ++ string_of_int(submissionNumber)}
      href={linkUrl(SubmissionMeta.id(submission), filterString)}
      key={SubmissionMeta.id(submission)}
      className={cardClasses(submission, selected)}>
      {submissionInfoCardContent(submission, submissionNumber)}
    </Link>
  }
}
