%%raw(`import "./CoursesStudents__StudentOverlay.css"`)

@module("../../shared/images/reviewed-empty.svg")
external reviewedEmptyImage: string = "default"

open CoursesStudents__Types

type state = {loading: bool}

let str = React.string

let tr = I18n.t(~scope="components.CoursesStudents__SubmissionsList", ...)
let ts = I18n.t(~scope="shared", ...)

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

  ignore(
    Js.Promise.then_(
      response => {
        updateStudentSubmissions(
          setState,
          updateSubmissionsCB,
          response["studentSubmissions"]["pageInfo"]["endCursor"],
          response["studentSubmissions"]["pageInfo"]["hasNextPage"],
          submissions,
          response["studentSubmissions"]["nodes"],
        )
        Js.Promise.resolve()
      },
      StudentSubmissionsQuery.make({
        studentId,
        after: cursor,
        sortDirection: #Descending,
      }),
    ),
  )
}

let showSubmissionStatus = submission =>
  switch Submission.evaluatedAt(submission) {
  | Some(_datetime) =>
    Submission.failed(submission)
      ? <div
          className="bg-red-100 border border-red-500 shrink-0 leading-normal text-red-800 font-semibold px-3 py-px rounded">
          {str(ts("rejected"))}
        </div>
      : <div
          className="bg-green-100 border border-green-500 shrink-0 leading-normal text-green-800 font-semibold px-3 py-px rounded">
          {str(ts("completed"))}
        </div>

  | None =>
    <div
      className="bg-orange-100 border border-orange-300 shrink-0 leading-normal text-orange-600 font-semibold px-3 py-px rounded">
      {str(Submission.timeDistance(submission))}
    </div>
  }

let submissionCardClasses = submission =>
  "flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-s-3 p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-e-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md " ++
  switch Submission.evaluatedAt(submission) {
  | Some(_datetime) => Submission.failed(submission) ? "border-red-500" : "border-green-500"
  | None => "border-orange-400"
  }

let showSubmission = submissions => <div> {React.array(Array.map(submission =>
        <a
          key={Submission.id(submission)}
          href={"/submissions/" ++ (Submission.id(submission) ++ "/review")}
          target="_blank">
          <div
            key={Submission.id(submission)}
            ariaLabel={"student-submission-card-" ++ Submission.id(submission)}
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
                  {str(tr("submitted_on") ++ Submission.createdAtPretty(submission))}
                </span>
              </div>
            </div>
            <div className="w-auto md:w-1/4 text-xs flex justify-end mt-2 md:mt-0">
              {showSubmissionStatus(submission)}
            </div>
          </div>
        </a>
      , Submission.sort(submissions)))} </div>

let showSubmissions = submissions =>
  ArrayUtils.isEmpty(submissions)
    ? <div className="course-review__reviewed-empty text-lg font-semibold text-center py-4">
        <h5 className="py-4 mt-4 bg-gray-50 text-gray-800 font-semibold">
          {str(tr("no_revied_submission"))}
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
              {str(ts("load_more"))}
            </button>}
      </div>
    | FullyLoaded(submissions) => showSubmissions(submissions)
    }}
  </div>
}
