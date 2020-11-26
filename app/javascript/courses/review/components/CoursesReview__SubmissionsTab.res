@bs.module
external reviewedEmptyImage: string = "../../shared/images/reviewed-empty.svg"
@bs.module
external pendingEmptyImage: string = "../images/pending-empty.svg"

open CoursesReview__Types

let str = React.string

type state =
  | Loading
  | Reloading
  | Loaded

module SubmissionsQuery = %graphql(
  `
    query SubmissionsQuery($courseId: ID!, $status: SubmissionStatus!, $sortDirection: SortDirection!,$sortCriterion: SubmissionSortCriterion!, $levelId: ID, $coachId: ID, $after: String) {
      submissions(courseId: $courseId, status: $status, sortDirection: $sortDirection, sortCriterion: $sortCriterion, levelId: $levelId, coachId: $coachId, first: 20, after: $after) {
        nodes {
          id,
          title,
          userNames,
          evaluatedAt,
          passedAt,
          feedbackSent,
          levelId,
          createdAt,
          targetId,
          coachIds,
          teamName
        }
        pageInfo {
          endCursor,
          hasNextPage
        }
        totalCount
      }
    }
  `
)

let updateSubmissions = (
  setState,
  endCursor,
  hasNextPage,
  totalCount,
  submissions,
  selectedTab,
  updateSubmissionsCB,
  nodes,
) => {
  let newSubmissionsList =
    Js.Array.map(IndexSubmission.decodeJs, nodes)->Js.Array.concat(submissions)

  updateSubmissionsCB(
    ~submissions=newSubmissionsList,
    ~selectedTab,
    ~hasNextPage,
    ~totalCount,
    ~endCursor,
  )

  setState(_ => Loaded)
}

let getSubmissions = (
  courseId,
  cursor,
  setState,
  selectedLevel,
  selectedCoach,
  sortBy,
  selectedTab,
  submissions,
  updateSubmissionsCB,
) => {
  setState(state =>
    switch state {
    | Loaded
    | Reloading =>
      Reloading
    | Loading => Loading
    }
  )

  let levelId = selectedLevel |> OptionUtils.map(level => level |> Level.id)
  let coachId = selectedCoach |> OptionUtils.map(coach => coach |> Coach.id)
  let sortDirection = SubmissionsSorting.sortDirection(sortBy)
  let sortCriterion = SubmissionsSorting.sortCriterion(sortBy)
  SubmissionsQuery.make(
    ~courseId,
    ~status=selectedTab,
    ~sortDirection,
    ~sortCriterion,
    ~levelId?,
    ~coachId?,
    ~after=?cursor,
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    response["submissions"]["nodes"] |> updateSubmissions(
      setState,
      response["submissions"]["pageInfo"]["endCursor"],
      response["submissions"]["pageInfo"]["hasNextPage"],
      response["submissions"]["totalCount"],
      submissions,
      selectedTab,
      updateSubmissionsCB,
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let submissionStatus = submission => {
  let classes = "border flex-shrink-0 leading-normal font-semibold px-3 py-px rounded "

  let (className, text) = if submission |> IndexSubmission.pendingReview {
    (classes ++ "bg-orange-100 text-orange-600", submission |> IndexSubmission.timeDistance)
  } else if submission |> IndexSubmission.failed {
    (classes ++ "bg-red-100 border-red-500 text-red-800", "Rejected")
  } else {
    (classes ++ "bg-green-100 border-green-500 text-green-800", "Completed")
  }

  <div className> {text |> str} </div>
}

let feedbackSentNotice = feedbackSent =>
  feedbackSent
    ? <div
        className="bg-primary-100 text-primary-600 border border-transparent flex-shrink-0 leading-normal font-semibold px-3 py-px rounded mr-3">
        {"Feedback Sent" |> str}
      </div>
    : React.null

let submissionCardClasses = submission =>
  "flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-l-3 p-3 md:py-6 md:px-5 mb-4 cursor-pointer rounded-r-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md " ++ if (
    submission |> IndexSubmission.pendingReview
  ) {
    "border-orange-400"
  } else if submission |> IndexSubmission.failed {
    "border-red-500"
  } else {
    "border-green-500"
  }

let showSubmission = (submissions, levels) =>
  <div id="submissions"> {submissions |> Array.map(submission =>
      <Link
        href={"/submissions/" ++ ((submission |> IndexSubmission.id) ++ "/review")}
        key={submission |> IndexSubmission.id}
        ariaLabel={"Submission " ++ (submission |> IndexSubmission.id)}
        className={submissionCardClasses(submission)}>
        <div className="w-full md:w-3/4">
          <div className="block text-sm md:pr-2">
            <span className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
              {submission
              |> IndexSubmission.levelId
              |> Level.unsafeLevelNumber(levels, "SubmissionsTab")
              |> str}
            </span>
            <span className="ml-2 font-semibold text-base">
              {submission |> IndexSubmission.title |> str}
            </span>
          </div>
          <div className="mt-1 ml-px text-xs text-gray-900">
            {switch submission |> IndexSubmission.teamName {
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
              {"on " ++ (submission |> IndexSubmission.createdAtPretty) |> str}
            </span>
          </div>
        </div>
        <div className="w-auto md:w-1/4 text-xs flex justify-end mt-2 md:mt-0">
          {feedbackSentNotice(submission |> IndexSubmission.feedbackSent)}
          {submissionStatus(submission)}
        </div>
      </Link>
    ) |> React.array} </div>

let showSubmissions = (submissions, selectedTab, levels) => {
  let imageSrc = switch selectedTab {
  | #Pending => pendingEmptyImage
  | #Reviewed => reviewedEmptyImage
  }

  submissions |> ArrayUtils.isEmpty
    ? <div className="course-review__submissions-empty text-lg font-semibold text-center py-4">
        <h5 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
          {"No submissions found" |> str}
        </h5>
        <img className="w-3/4 md:w-1/2 mx-auto mt-2" src=imageSrc />
      </div>
    : showSubmission(submissions, levels)
}

@react.component
let make = (
  ~courseId,
  ~selectedTab,
  ~selectedLevel,
  ~selectedCoach,
  ~sortBy,
  ~levels,
  ~submissions,
  ~updateSubmissionsCB,
  ~reloadAt,
) => {
  let (state, setState) = React.useState(() => Loading)

  React.useEffect5(() => {
    let needsReloading =
      submissions |> Submissions.needsReloading(selectedLevel, selectedCoach, sortBy)
    if needsReloading {
      setState(_ => Reloading)

      getSubmissions(
        courseId,
        None,
        setState,
        selectedLevel,
        selectedCoach,
        sortBy,
        selectedTab,
        [],
        updateSubmissionsCB,
      )
    }

    None
  }, (selectedLevel, selectedCoach, sortBy, selectedTab, reloadAt))

  <div>
    <LoadingSpinner loading={state == Reloading} />
    {switch (submissions: Submissions.t) {
    | Unloaded => SkeletonLoading.multiple(~count=10, ~element=SkeletonLoading.card())
    | PartiallyLoaded({submissions}, cursor) =>
      <div>
        {showSubmissions(submissions, selectedTab, levels)}
        {state == Loading
          ? SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
          : <button
              className="btn btn-primary-ghost cursor-pointer w-full mt-4"
              onClick={_ => {
                setState(_state => Loading)
                getSubmissions(
                  courseId,
                  Some(cursor),
                  setState,
                  selectedLevel,
                  selectedCoach,
                  sortBy,
                  selectedTab,
                  submissions,
                  updateSubmissionsCB,
                )
              }}>
              {"Load More..." |> str}
            </button>}
      </div>
    | FullyLoaded({submissions}) => showSubmissions(submissions, selectedTab, levels)
    }}
  </div>
}
