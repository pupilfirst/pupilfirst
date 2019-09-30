[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

type state = {
  loading: bool,
  hasNextPage: bool,
  endCursor: option(string),
};

module ReviewedSubmissionsQuery = [%graphql
  {|
    query($courseId: ID!, $levelId: ID, $after: String) {
      reviewedSubmissions(courseId: $courseId, levelId: $levelId, first: 20, after: $after) {
        nodes {
        id,title,userNames,failed,feedbackSent,levelId,createdAt,targetId
        }
        pageInfo{
          endCursor,hasNextPage
        }
      }
  }
|}
];

let updateReviewedSubmissions =
    (
      setState,
      endCursor,
      hasNextPage,
      reviewedSubmissions,
      updateReviewedSubmissionsCB,
      nodes,
    ) => {
  updateReviewedSubmissionsCB(
    reviewedSubmissions
    |> Array.append(
         (
           switch (nodes) {
           | None => [||]
           | Some(submissionsArray) =>
             submissionsArray |> SubmissionInfo.decodeJS
           }
         )
         |> Array.to_list
         |> List.flatten
         |> Array.of_list,
       ),
  );
  setState(_ => {loading: false, endCursor, hasNextPage});
};

let getReviewedSubmissions =
    (
      authenticityToken,
      courseId,
      cursor,
      setState,
      selectedLevel,
      reviewedSubmissions,
      updateReviewedSubmissionsCB,
    ) => {
  setState(state => {...state, loading: true});
  (
    switch (selectedLevel, cursor) {
    | (Some(level), Some(cursor)) =>
      ReviewedSubmissionsQuery.make(
        ~courseId,
        ~levelId=level |> Level.id,
        ~after=cursor,
        (),
      )
    | (Some(level), None) =>
      ReviewedSubmissionsQuery.make(~courseId, ~levelId=level |> Level.id, ())
    | (None, Some(cursor)) =>
      ReviewedSubmissionsQuery.make(~courseId, ~after=cursor, ())
    | (None, None) => ReviewedSubmissionsQuery.make(~courseId, ())
    }
  )
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##reviewedSubmissions##nodes
       |> updateReviewedSubmissions(
            setState,
            response##reviewedSubmissions##pageInfo##endCursor,
            response##reviewedSubmissions##pageInfo##hasNextPage,
            reviewedSubmissions,
            updateReviewedSubmissionsCB,
          );
       Js.Promise.resolve();
     })
  |> ignore;
};

let loadSubmissions =
    (
      authenticityToken,
      courseId,
      state,
      setState,
      reviewedSubmissions,
      selectedLevel,
      updateReviewedSubmissionsCB,
      (),
    ) => {
  reviewedSubmissions |> ArrayUtils.isEmpty ?
    getReviewedSubmissions(
      authenticityToken,
      courseId,
      state.endCursor,
      setState,
      selectedLevel,
      reviewedSubmissions,
      updateReviewedSubmissionsCB,
    ) :
    ();

  None;
};
let showSubmissionStatus = failed =>
  failed ?
    <div
      className="bg-red-100 border border-red-500 flex-shrink-0 leading-normal text-red-800 font-semibold px-3 py-px rounded">
      {"Failed" |> str}
    </div> :
    <div
      className="bg-green-100 border border-green-500 flex-shrink-0 leading-normal text-green-800 font-semibold px-3 py-px rounded">
      {"Passed" |> str}
    </div>;

let showFeedbackSent = feedbackSent =>
  feedbackSent ?
    <div
      className="bg-primary-100 text-primary-600 border border-transparent flex-shrink-0 leading-normal font-semibold px-3 py-px rounded mr-3">
      {"Feedback Sent" |> str}
    </div> :
    React.null;

let showLoadMoreButton =
    (
      authenticityToken,
      courseId,
      setState,
      selectedLevel,
      cursor,
      reviewedSubmissions,
      updateReviewedSubmissionsCB,
    ) =>
  <button
    className="btn btn-primary-ghost cursor-pointer w-full mt-8"
    onClick={
      _ =>
        getReviewedSubmissions(
          authenticityToken,
          courseId,
          cursor,
          setState,
          selectedLevel,
          reviewedSubmissions,
          updateReviewedSubmissionsCB,
        )
    }>
    {"Load More..." |> str}
  </button>;

let submissionCardClasses = status =>
  "flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-l-3 p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md "
  ++ (
    switch (status) {
    | Some(s) =>
      s |> SubmissionInfo.failed ? "border-red-500" : "border-green-500"
    | None => "border-gray-600"
    }
  );

let showSubmission = (submissions, levels, openOverlayCB) =>
  <div>
    {
      submissions
      |> SubmissionInfo.sort
      |> Array.map(submission =>
           <div
             key={submission |> SubmissionInfo.id}
             onClick={_ => openOverlayCB(submission |> SubmissionInfo.id)}
             className={
               submissionCardClasses(submission |> SubmissionInfo.status)
             }>
             <div className="w-full md:w-3/4">
               <div className="block text-sm md:pr-2">
                 <span
                   className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
                   {
                     submission
                     |> SubmissionInfo.levelId
                     |> Level.unsafeLevelNumber(
                          levels,
                          "ShowReviewedSubmission",
                        )
                     |> str
                   }
                 </span>
                 <span className="ml-2 font-semibold text-base">
                   {submission |> SubmissionInfo.title |> str}
                 </span>
               </div>
               <div className="mt-1 ml-px text-xs text-gray-900">
                 <span> {"Submitted by " |> str} </span>
                 <span className="font-semibold">
                   {submission |> SubmissionInfo.userNames |> str}
                 </span>
                 <span className="ml-1">
                   {
                     "on "
                     ++ (submission |> SubmissionInfo.createdAtPretty)
                     |> str
                   }
                 </span>
               </div>
             </div>
             {
               switch (submission |> SubmissionInfo.status) {
               | Some(status) =>
                 <div
                   className="w-auto md:w-1/4 text-xs flex justify-end mt-2 md:mt-0">
                   {showFeedbackSent(status |> SubmissionInfo.feedbackSent)}
                   {showSubmissionStatus(status |> SubmissionInfo.failed)}
                 </div>
               | None => React.null
               }
             }
           </div>
         )
      |> React.array
    }
  </div>;

[@react.component]
let make =
    (
      ~authenticityToken,
      ~courseId,
      ~selectedLevel,
      ~levels,
      ~openOverlayCB,
      ~reviewedSubmissions,
      ~updateReviewedSubmissionsCB,
    ) => {
  let (state, setState) =
    React.useState(() =>
      {loading: false, hasNextPage: false, endCursor: None}
    );

  React.useEffect1(
    loadSubmissions(
      authenticityToken,
      courseId,
      state,
      setState,
      reviewedSubmissions,
      selectedLevel,
      updateReviewedSubmissionsCB,
    ),
    [|selectedLevel|],
  );

  <div>
    {
      switch (reviewedSubmissions) {
      | [||] =>
        state.loading ?
          React.null :
          <div
            className="text-lg font-semibold text-center rounded-lg p-8 bg-white shadow text-gray-700">
            {"No Reviewed Submission" |> str}
          </div>
      | _ => showSubmission(reviewedSubmissions, levels, openOverlayCB)
      }
    }
    {
      switch (state.loading, state.hasNextPage, state.endCursor) {
      | (true, _, _) =>
        <div
          className="text-sm text-center font-semibold bg-gray-300 p-2 rounded mt-8">
          {"Loading Submissions..." |> str}
        </div>
      | (false, false, _)
      | (false, true, None) => React.null
      | (false, true, Some(_)) =>
        showLoadMoreButton(
          authenticityToken,
          courseId,
          setState,
          selectedLevel,
          state.endCursor,
          reviewedSubmissions,
          updateReviewedSubmissionsCB,
        )
      }
    }
  </div>;
};
