[@bs.config {jsx: 3}];
let reviewedEmptyImage: string = [%raw
  "require('../images/reviewed-empty.svg')"
];

open CoursesReview__Types;
let str = React.string;

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
      setLoading,
      endCursor,
      hasNextPage,
      reviewedSubmissions,
      updateReviewedSubmissionsCB,
      nodes,
    ) => {
  updateReviewedSubmissionsCB(
    ~reviewedSubmissions=
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
    ~hasNextPage,
    ~endCursor,
  );
  setLoading(_ => false);
};

let getReviewedSubmissions =
    (
      authenticityToken,
      courseId,
      cursor,
      setLoading,
      selectedLevel,
      reviewedSubmissions,
      updateReviewedSubmissionsCB,
    ) => {
  setLoading(_ => true);
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
            setLoading,
            response##reviewedSubmissions##pageInfo##endCursor,
            response##reviewedSubmissions##pageInfo##hasNextPage,
            reviewedSubmissions,
            updateReviewedSubmissionsCB,
          );
       Js.Promise.resolve();
     })
  |> ignore;
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
             ariaLabel={
               "reviewed-submission-card-" ++ (submission |> SubmissionInfo.id)
             }
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
      ~endCursor,
      ~hasNextPage,
      ~updateReviewedSubmissionsCB,
    ) => {
  let loaded =
    switch (reviewedSubmissions, hasNextPage) {
    | ([||], hasNextPage) => !hasNextPage
    | (_loadedSubmissions, _hasNextPage) => false
    };
  let (loading, setLoading) = React.useState(() => !loaded);

  React.useEffect1(
    () => {
      loaded ?
        () :
        getReviewedSubmissions(
          authenticityToken,
          courseId,
          endCursor,
          setLoading,
          selectedLevel,
          reviewedSubmissions,
          updateReviewedSubmissionsCB,
        );
      None;
    },
    [|selectedLevel|],
  );

  <div>
    {
      switch (reviewedSubmissions) {
      | [||] =>
        !loaded ?
          SkeletonLoading.multiple(
            ~count=10,
            ~element=SkeletonLoading.card(),
          ) :
          <div
            className="text-lg font-semibold text-center rounded-lg p-8 bg-white shadow">
            <img className="w-3/4 md:w-1/2 mx-auto" src=reviewedEmptyImage />
            <h4 className="mt-2"> {"No Reviewed Submission" |> str} </h4>
          </div>
      | _ => showSubmission(reviewedSubmissions, levels, openOverlayCB)
      }
    }
    {
      switch (loading, hasNextPage, endCursor) {
      | (true, _, _) =>
        SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
      | (false, false, _)
      | (false, true, None) => React.null
      | (false, true, Some(_)) =>
        showLoadMoreButton(
          authenticityToken,
          courseId,
          setLoading,
          selectedLevel,
          endCursor,
          reviewedSubmissions,
          updateReviewedSubmissionsCB,
        )
      }
    }
  </div>;
};
