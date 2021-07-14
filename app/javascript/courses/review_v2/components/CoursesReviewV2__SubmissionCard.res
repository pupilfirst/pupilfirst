@bs.module
external reviewedEmptyImage: string = "../../shared/images/reviewed-empty.svg"
@bs.module
external pendingEmptyImage: string = "../images/pending-empty.svg"

open CoursesReview__Types

let str = React.string

let submissionStatus = submission => {
  let classes = "border flex-shrink-0 leading-normal font-semibold px-3 py-px rounded "

  let (className, text) = if IndexSubmission.pendingReview(submission) {
    (classes ++ "bg-orange-100 text-orange-600", IndexSubmission.timeDistance(submission))
  } else if IndexSubmission.failed(submission) {
    (classes ++ "bg-red-100 border-red-500 text-red-800", "Rejected")
  } else {
    (classes ++ "bg-green-100 border-green-500 text-green-800", "Completed")
  }
  <div className> {str(text)} </div>
}

let feedbackSentNotice = feedbackSent =>
  ReactUtils.nullUnless(
    <div
      className="bg-primary-100 text-primary-600 border border-transparent flex-shrink-0 leading-normal font-semibold px-3 py-px rounded mr-3">
      {str("Feedback Sent")}
    </div>,
    feedbackSent,
  )

let submissionCardClasses = submission =>
  "flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-l-3 p-3 md:py-6 md:px-5 mb-4 cursor-pointer rounded-r-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md " ++ if (
    IndexSubmission.pendingReview(submission)
  ) {
    "border-orange-400"
  } else if IndexSubmission.failed(submission) {
    "border-red-500"
  } else {
    "border-green-500"
  }

let openSubmission = (submission, event) => {
  event->ReactEvent.Mouse.preventDefault
  RescriptReactRouter.push("/submissions/" ++ (IndexSubmission.id(submission) ++ "/review_v2"))
}

let showSubmission = (submissions, filterString) =>
  <div id="submissions"> {Js.Array.map(submission =>
      <Link
        href={"/submissions/" ++
        (IndexSubmission.id(submission) ++
        "/review_v2" ++
        "?" ++
        filterString)}
        key={IndexSubmission.id(submission)}
        ariaLabel={"Submission " ++ IndexSubmission.id(submission)}
        className={submissionCardClasses(submission)}>
        <div className="w-full md:w-3/4">
          <div className="block text-sm md:pr-2">
            <span className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
              {str("Level " ++ string_of_int(IndexSubmission.levelNumber(submission)))}
            </span>
            <span className="ml-2 font-semibold text-base">
              {IndexSubmission.title(submission)->str}
            </span>
          </div>
          <div className="mt-1 ml-px text-xs text-gray-900">
            {switch IndexSubmission.teamName(submission) {
            | Some(name) =>
              <span>
                {str("Submitted by team: ")} <span className="font-semibold"> {str(name)} </span>
              </span>
            | None =>
              <span>
                {str("Submitted by: ")}
                <span className="font-semibold">
                  {IndexSubmission.userNames(submission)->str}
                </span>
              </span>
            }}
            <span className="ml-1">
              {("on " ++ IndexSubmission.createdAtPretty(submission))->str}
            </span>
          </div>
        </div>
        <div className="w-auto md:w-1/4 text-xs flex justify-end mt-2 md:mt-0">
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
        <h5 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
          {"No submissions found"->str}
        </h5>
        <img className="w-3/4 md:w-1/2 mx-auto mt-2" src=imageSrc />
      </div>
    : showSubmission(submissions, filterString)
}
