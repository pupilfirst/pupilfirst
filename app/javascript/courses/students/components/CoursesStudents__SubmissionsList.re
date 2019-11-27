[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__StudentOverlay.css")|}];
let reviewedEmptyImage: string = [%raw
  "require('../images/reviewed-empty.svg')"
];

open CoursesStudents__Types;

type state = {
  submissions: Submissions.t,
  loading: bool,
};

let str = React.string;

module StudentSubmissionsQuery = [%graphql
  {|
   query($studentId: ID!, $after: String) {
    studentSubmissions(studentId: $studentId, after: $after, first: 20 ) {
       nodes {
         id
        createdAt
        levelId
        passedAt
        title
       }
       pageInfo {
         hasNextPage
         endCursor
       }
      }
    }
   |}
];

let updateStudentSubmissions =
    (setState, endCursor, hasNextPage, submissions, nodes) => {
  let updatedSubmissions =
    Array.append(
      (
        switch (nodes) {
        | None => [||]
        | Some(submissionsArray) => submissionsArray |> Submission.makeFromJs
        }
      )
      |> Array.to_list
      |> List.flatten
      |> Array.of_list,
      submissions,
    );
  setState(_ =>
    {
      loading: false,
      submissions:
        switch (hasNextPage, endCursor) {
        | (_, None)
        | (false, Some(_)) => FullyLoaded(updatedSubmissions)
        | (true, Some(cursor)) =>
          PartiallyLoaded(updatedSubmissions, cursor)
        },
    }
  );
};

let getStudentSubmissions =
    (authenticityToken, studentId, cursor, setState, submissions) => {
  setState(state => {...state, loading: true});
  (
    switch (cursor) {
    | Some(cursor) =>
      StudentSubmissionsQuery.make(~studentId, ~after=cursor, ())
    | None => StudentSubmissionsQuery.make(~studentId, ())
    }
  )
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##studentSubmissions##nodes
       |> updateStudentSubmissions(
            setState,
            response##studentSubmissions##pageInfo##endCursor,
            response##studentSubmissions##pageInfo##hasNextPage,
            submissions,
          );
       Js.Promise.resolve();
     })
  |> ignore;
};

let showSubmissionStatus = failed =>
  failed
    ? <div
        className="bg-red-100 border border-red-500 flex-shrink-0 leading-normal text-red-800 font-semibold px-3 py-px rounded">
        {"Failed" |> str}
      </div>
    : <div
        className="bg-green-100 border border-green-500 flex-shrink-0 leading-normal text-green-800 font-semibold px-3 py-px rounded">
        {"Passed" |> str}
      </div>;

let submissionCardClasses = submission =>
  "flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-l-3 p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md "
  ++ (submission |> Submission.failed ? "border-red-500" : "border-green-500");

let showSubmission = (submissions, levels) =>
  <div>
    {submissions
     |> Submission.sort
     |> Array.map(submission =>
          <div
            key={submission |> Submission.id}
            onClick={_ => Js.log("submission")}
            ariaLabel={
              "reviewed-submission-card-" ++ (submission |> Submission.id)
            }
            className={submissionCardClasses(submission)}>
            <div className="w-full md:w-3/4">
              <div className="block text-sm md:pr-2">
                <span
                  className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
                  {submission
                   |> Submission.levelId
                   |> Level.unsafeLevelNumber(
                        levels,
                        "ShowReviewedSubmission",
                      )
                   |> str}
                </span>
                <span className="ml-2 font-semibold text-base">
                  {submission |> Submission.title |> str}
                </span>
              </div>
              <div className="mt-1 ml-px text-xs text-gray-900">
                <span className="ml-1">
                  {"Submitted on "
                   ++ (submission |> Submission.createdAtPretty)
                   |> str}
                </span>
              </div>
            </div>
            {<div
               className="w-auto md:w-1/4 text-xs flex justify-end mt-2 md:mt-0">
               {showSubmissionStatus(submission |> Submission.failed)}
             </div>}
          </div>
        )
     |> React.array}
  </div>;

let showSubmissions = (submissions, levels) =>
  submissions |> ArrayUtils.isEmpty
    ? <div
        className="course-review__reviewed-empty text-lg font-semibold text-center py-4">
        <h5 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
          {"No Reviewed Submission" |> str}
        </h5>
        <img className="w-3/4 md:w-1/2 mx-auto mt-2" src=reviewedEmptyImage />
      </div>
    : showSubmission(submissions, levels);

[@react.component]
let make = (~studentId, ~levels) => {
  let (state, setState) =
    React.useState(() => {submissions: Unloaded, loading: false});
  React.useEffect1(
    () => {
      getStudentSubmissions(
        AuthenticityToken.fromHead(),
        studentId,
        None,
        setState,
        [||],
      );
      None;
    },
    [|studentId|],
  );
  <div>
    {switch (state.submissions) {
     | Unloaded =>
       SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
     | PartiallyLoaded(submissions, cursor) =>
       <div>
         {showSubmissions(submissions, levels)}
         {state.loading
            ? SkeletonLoading.multiple(
                ~count=3,
                ~element=SkeletonLoading.card(),
              )
            : <button
                className="btn btn-primary-ghost cursor-pointer w-full mt-8"
                onClick={_ =>
                  getStudentSubmissions(
                    AuthenticityToken.fromHead(),
                    studentId,
                    Some(cursor),
                    setState,
                    submissions,
                  )
                }>
                {"Load More..." |> str}
              </button>}
       </div>
     | FullyLoaded(submissions) => showSubmissions(submissions, levels)
     }}
  </div>;
};
