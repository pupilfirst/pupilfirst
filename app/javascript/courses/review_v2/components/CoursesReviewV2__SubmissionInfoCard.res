open CoursesReview__Types
let str = React.string

let cardClasses = submission =>
  "mt-6 rounded-r-lg bg-white border-l-3 " ++
  switch (SubmissionMeta.passedAt(submission), SubmissionMeta.evaluatedAt(submission)) {
  | (None, None) => "border-orange-300"
  | (None, Some(_)) => "border-red-500"
  | (Some(_), None)
  | (Some(_), Some(_)) => "border-green-500"
  }

let showSubmissionStatus = submission => {
  let (text, classes) = switch (
    SubmissionMeta.passedAt(submission),
    SubmissionMeta.evaluatedAt(submission),
  ) {
  | (None, None) => ("Pending Review", "bg-orange-100 border border-orange-500 text-orange-800 ")
  | (None, Some(_)) => ("Rejected", "bg-red-100 border border-red-500 text-red-700")
  | (Some(_), None)
  | (Some(_), Some(_)) => ("Completed", "bg-green-100 border border-green-500 text-green-800")
  }
  <div className={"font-semibold px-3 py-px rounded " ++ classes}>
    <span className="hidden md:block"> {text->str} </span>
    <span className="md:hidden block">
      <PfIcon className="if i-check-square-alt-solid if-fw" />
    </span>
  </div>
}

@react.component
let make = (~submission, ~submissionNumber) =>
  <div className={cardClasses(submission)}>
    <div className="rounded-r-lg shadow">
      <div
        className="p-4 md:px-6 md:py-5 border-b bg-white flex flex-row items-center justify-between">
        <div className="flex flex-col pr-4">
          <h2 className="font-semibold text-sm lg:text-base leading-tight">
            {("Submission #" ++ string_of_int(submissionNumber))->str}
          </h2>
          <span className="text-xs text-gray-800 pt-px">
            {submission->SubmissionMeta.createdAt->DateFns.formatPreset(~year=true, ())->str}
          </span>
        </div>
        <div className="text-xs flex w-auto mt-2 sm:mt-0">
          {ReactUtils.nullUnless(
            <div
              className="bg-primary-100 text-primary-600 border border-transparent font-semibold px-3 py-px rounded mr-3">
              <span className="hidden md:block"> {"Feedback Sent"->str} </span>
              <span className="md:hidden block">
                <PfIcon className="if i-comment-alt-solid if-fw" />
              </span>
            </div>,
            (SubmissionMeta.feedbackSent(submission)),
          )}
          {showSubmissionStatus(submission)}
        </div>
      </div>
    </div>
  </div>
