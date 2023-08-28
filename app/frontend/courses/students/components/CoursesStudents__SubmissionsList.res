%%raw(`import "./CoursesStudents__StudentOverlay.css"`)

@module("../../shared/images/reviewed-empty.svg")
external reviewedEmptyImage: string = "default"

open CoursesStudents__Types

type state = {loading: bool}

let str = React.string

let tr = I18n.t(~scope="components.CoursesStudents__SubmissionsList")
let ts = I18n.t(~scope="shared")

module StudentSubmissionsQuery = %graphql(`
   query StudentSubmissionsQuery($studentId: ID!, $after: String, $sortDirection: SortDirection!) {
    studentSubmissions(studentId: $studentId, after: $after, first: 20 , sortDirection: $sortDirection) {
       nodes {
         id
        createdAt
        passedAt
        title
        evaluatedAt
        milestoneNumber
       }
       pageInfo {
         hasNextPage
         endCursor
       }
      }
    }
   `)

let updateStudentSubmissions = (
  setState,
  updateSubmissionsCB,
  endCursor,
  hasNextPage,
  submissions,
  nodes,
) => {
  let updatedSubmissions = Js.Array.concat(Submission.makeFromJs(nodes), submissions)

  let submissionsData: Submissions.t = switch (hasNextPage, endCursor) {
  | (true, None)
  | (false, _) =>
    FullyLoaded(updatedSubmissions)
  | (true, Some(cursor)) => PartiallyLoaded(updatedSubmissions, cursor)
  }

  updateSubmissionsCB(submissionsData)
  setState(_ => {loading: false})
}

let getStudentSubmissions = (studentId, cursor, setState, submissions, updateSubmissionsCB) => {
  setState(_ => {loading: true})

  StudentSubmissionsQuery.make({
    studentId: studentId,
    after: cursor,
    sortDirection: #Descending,
  })
  |> Js.Promise.then_(response => {
    updateStudentSubmissions(
      setState,
      updateSubmissionsCB,
      response["studentSubmissions"]["pageInfo"]["endCursor"],
      response["studentSubmissions"]["pageInfo"]["hasNextPage"],
      submissions,
      response["studentSubmissions"]["nodes"],
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let showSubmissionStatus = submission =>
  switch submission |> Submission.evaluatedAt {
  | Some(_datetime) =>
    submission |> Submission.failed
      ? <div
          className="bg-red-100 border border-red-500 shrink-0 leading-normal text-red-800 font-semibold px-3 py-px rounded">
          {ts("rejected") |> str}
        </div>
      : <div
          className="bg-green-100 border border-green-500 shrink-0 leading-normal text-green-800 font-semibold px-3 py-px rounded">
          {ts("completed") |> str}
        </div>

  | None =>
    <div
      className="bg-orange-100 border border-orange-300 shrink-0 leading-normal text-orange-600 font-semibold px-3 py-px rounded">
      {submission |> Submission.timeDistance |> str}
    </div>
  }

let submissionCardClasses = submission =>
  "flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-s-3 p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-e-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md " ++
  switch submission |> Submission.evaluatedAt {
  | Some(_datetime) => submission |> Submission.failed ? "border-red-500" : "border-green-500"
  | None => "border-orange-400"
  }

let showSubmission = submissions =>
  <div>
    {submissions
    |> Submission.sort
    |> Array.map(submission =>
      <a
        key={submission |> Submission.id}
        href={"/submissions/" ++ ((submission |> Submission.id) ++ "/review")}
        target="_blank">
        <div
          key={submission |> Submission.id}
          ariaLabel={"student-submission-card-" ++ (submission |> Submission.id)}
          className={submissionCardClasses(submission)}>
          <div className="w-full md:w-3/4">
            <div className="block text-sm md:pe-2">
              <span className="ms-1 font-semibold text-base">
                {(Belt.Option.mapWithDefault(Submission.milestoneNumber(submission), "", number =>
                  ts("m") ++ string_of_int(number) ++ " - "
                ) ++
                submission->Submission.title)->str}
              </span>
            </div>
            <div className="mt-1 ms-px text-xs text-gray-900">
              <span className="ms-1">
                {tr("submitted_on") ++ (submission |> Submission.createdAtPretty) |> str}
              </span>
            </div>
          </div>
          <div className="w-auto md:w-1/4 text-xs flex justify-end mt-2 md:mt-0">
            {showSubmissionStatus(submission)}
          </div>
        </div>
      </a>
    )
    |> React.array}
  </div>

let showSubmissions = submissions =>
  submissions |> ArrayUtils.isEmpty
    ? <div className="course-review__reviewed-empty text-lg font-semibold text-center py-4">
        <h5 className="py-4 mt-4 bg-gray-50 text-gray-800 font-semibold">
          {tr("no_revied_submission") |> str}
        </h5>
        <img className="w-3/4 md:w-1/2 mx-auto mt-2" src=reviewedEmptyImage />
      </div>
    : showSubmission(submissions)

@react.component
let make = (~studentId, ~submissions, ~updateSubmissionsCB) => {
  let (state, setState) = React.useState(() => {loading: false})
  React.useEffect1(() => {
    switch submissions {
    | Submissions.Unloaded =>
      getStudentSubmissions(studentId, None, setState, [], updateSubmissionsCB)
    | FullyLoaded(_)
    | PartiallyLoaded(_) => ()
    }
    None
  }, [studentId])
  <div ariaLabel="student-submissions">
    {switch submissions {
    | Unloaded => SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
    | PartiallyLoaded(submissions, cursor) =>
      <div>
        {showSubmissions(submissions)}
        {state.loading
          ? SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
          : <button
              className="btn btn-primary-ghost cursor-pointer w-full mt-4"
              onClick={_ =>
                getStudentSubmissions(
                  studentId,
                  Some(cursor),
                  setState,
                  submissions,
                  updateSubmissionsCB,
                )}>
              {ts("load_more") |> str}
            </button>}
      </div>
    | FullyLoaded(submissions) => showSubmissions(submissions)
    }}
  </div>
}
