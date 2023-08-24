@module("../../shared/images/reviewed-empty.svg")
external reviewedEmptyImage: string = "default"
@module("../images/pending-empty.svg")
external pendingEmptyImage: string = "default"

let t = I18n.t(~scope="components.CoursesReview__SubmissionCard")
let ts = I18n.t(~scope="shared")

open CoursesReview__Types

let str = React.string

let submissionStatus = submission => {
  let classes = "shrink-0 leading-normal font-semibold px-2 py-px rounded "

  let (className, text) = if IndexSubmission.pendingReview(submission) {
    (classes ++ "bg-orange-100 text-orange-800", IndexSubmission.timeDistance(submission))
  } else if IndexSubmission.failed(submission) {
    (classes ++ "bg-red-100 text-red-800", t("rejected"))
  } else {
    (classes ++ "bg-green-100 text-green-800", t("completed"))
  }
  <div className> {str(text)} </div>
}

let feedbackSentNotice = feedbackSent =>
  ReactUtils.nullUnless(
    <div
      className="bg-primary-100 text-primary-600 border border-transparent shrink-0 leading-normal font-semibold px-2 py-px rounded me-3">
      {str(t("feedback_sent"))}
    </div>,
    feedbackSent,
  )

let submissionCardClasses = submission =>
  "flex flex-col lg:flex-row items-start lg:items-center justify-between bg-white border-s-3 p-3 lg:py-6 lg:px-5 mb-4 cursor-pointer rounded-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md focus:outline-none focus:border-primary-500 focus:ring-2 focus:ring-inset focus:ring-focusColor-500 " ++ if (
    IndexSubmission.pendingReview(submission)
  ) {
    "border-orange-400"
  } else if IndexSubmission.failed(submission) {
    "border-red-500"
  } else {
    "border-green-500"
  }

let showSubmission = (submissions, filterString) =>
  <div id="submissions"> {Js.Array.map(submission =>
      <Link
        key={IndexSubmission.id(submission)}
        props={"data-submission-id": IndexSubmission.id(submission)}
        href={`/submissions/${IndexSubmission.id(submission)}/review?${filterString}`}
        ariaLabel={"Submission " ++
        IndexSubmission.id(submission) ++
        ", Submitted by: " ++
        IndexSubmission.userNames(submission)}
        className={submissionCardClasses(submission)}>
        <div className="w-full lg:w-8/12">
          <div className="block text-sm lg:pe-4">
            <span className="font-semibold text-sm md:text-base">
              {(Belt.Option.mapWithDefault(
                IndexSubmission.milestoneNumber(submission),
                "",
                number => ts("m") ++ string_of_int(number) ++ " - ",
              ) ++
              IndexSubmission.title(submission))->str}
            </span>
          </div>
          <div className="mt-1 ms-px text-xs text-gray-900">
            {switch IndexSubmission.teamName(submission) {
            | Some(name) =>
              <span>
                {str(t("submitted_by_team"))} <span className="font-semibold"> {str(name)} </span>
              </span>
            | None =>
              <span>
                {str(t("submitted_by"))}
                <span className="font-semibold">
                  {IndexSubmission.userNames(submission)->str}
                </span>
              </span>
            }}
            <span
              className="ms-1"
              title={IndexSubmission.createdAt(submission)->DateFns.formatPreset(
                ~year=true,
                ~time=true,
                (),
              )}>
              {{
                t(
                  ~variables=[("created_at", IndexSubmission.createdAtPretty(submission))],
                  "created_at",
                )
              }->str}
            </span>
            {switch IndexSubmission.reviewer(submission) {
            | Some(reviewer) =>
              <span className="ms-1">
                {str(t("assigned_to"))}
                <span className="ms-1 font-semibold">
                  {{IndexSubmission.reviewerName(reviewer)}->str}
                </span>
                <span
                  className="text-xs text-gray-800 ms-1"
                  title={IndexSubmission.reviewerAssignedAt(reviewer)->DateFns.formatPreset(
                    ~year=true,
                    ~time=true,
                    (),
                  )}>
                  {DateFns.formatDistanceToNow(
                    IndexSubmission.reviewerAssignedAt(reviewer),
                    ~addSuffix=true,
                    (),
                  )->str}
                  {str(".")}
                </span>
              </span>
            | None => React.null
            }}
          </div>
        </div>
        <div className="w-auto lg:w-4/12 text-xs flex justify-end mt-2 lg:mt-0">
          {feedbackSentNotice(IndexSubmission.feedbackSent(submission))}
          {submissionStatus(submission)}
        </div>
      </Link>
    , submissions)->React.array} </div>

@react.component
let make = (~submissions, ~selectedTab, ~filterString) => {
  let imageSrc = Belt.Option.mapWithDefault(selectedTab, pendingEmptyImage, t =>
    switch t {
    | #Pending => pendingEmptyImage
    | #Reviewed => reviewedEmptyImage
    }
  )

  ArrayUtils.isEmpty(submissions)
    ? <div className="course-review__submissions-empty text-lg font-semibold text-center py-4">
        <h5 className="py-4 mt-4 bg-gray-50 text-gray-800 font-semibold">
          {t("no_submissions_found")->str}
        </h5>
        <img className="w-3/4 md:w-1/2 mx-auto mt-2" src=imageSrc />
      </div>
    : showSubmission(submissions, filterString)
}
