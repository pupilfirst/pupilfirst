let reviewedEmptyImage: string = [%raw
  "require('../../shared/images/reviewed-empty.svg')"
];

open CoursesReview__Types;

let str = React.string;

type state =
  | Loading
  | Reloading
  | Loaded;

module ReviewedSubmissionsQuery = [%graphql
  {|
    query ReviewedSubmissionsQuery($courseId: ID!, $levelId: ID, $coachId: ID, $after: String) {
      reviewedSubmissions(courseId: $courseId, levelId: $levelId, coachId: $coachId, first: 20, after: $after) {
        nodes {
          id,
          title,
          userNames,
          failed,
          feedbackSent,
          levelId,
          createdAt,
          targetId,
          coachIds
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
    ~reviewedSubmissions=
      reviewedSubmissions
      |> Array.append(
           (
             switch (nodes) {
             | None => [||]
             | Some(submissionsArray) =>
               submissionsArray |> IndexSubmission.decodeJs
             }
           )
           |> Array.to_list
           |> List.flatten
           |> Array.of_list,
         ),
    ~hasNextPage,
    ~endCursor,
  );
  setState(_ => Loaded);
};

let getReviewedSubmissions =
    (
      courseId,
      cursor,
      setState,
      selectedLevel,
      selectedCoach,
      reviewedSubmissions,
      updateReviewedSubmissionsCB,
    ) => {
  setState(state =>
    switch (state) {
    | Loaded
    | Reloading => Reloading
    | Loading => Loading
    }
  );

  let levelId = selectedLevel |> OptionUtils.map(level => level |> Level.id);
  let coachId = selectedCoach |> OptionUtils.map(coach => coach |> Coach.id);

  ReviewedSubmissionsQuery.make(
    ~courseId,
    ~levelId?,
    ~coachId?,
    ~after=?cursor,
    (),
  )
  |> GraphqlQuery.sendQuery
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

let submissionStatus = failed =>
  failed
    ? <div
        className="bg-red-100 border border-red-500 flex-shrink-0 leading-normal text-red-800 font-semibold px-3 py-px rounded">
        {"Failed" |> str}
      </div>
    : <div
        className="bg-green-100 border border-green-500 flex-shrink-0 leading-normal text-green-800 font-semibold px-3 py-px rounded">
        {"Passed" |> str}
      </div>;

let feedbackSentNotice = feedbackSent =>
  feedbackSent
    ? <div
        className="bg-primary-100 text-primary-600 border border-transparent flex-shrink-0 leading-normal font-semibold px-3 py-px rounded mr-3">
        {"Feedback Sent" |> str}
      </div>
    : React.null;

let submissionCardClasses = status =>
  "flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-l-3 p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md "
  ++ (
    switch (status) {
    | Some(s) =>
      s |> IndexSubmission.failed ? "border-red-500" : "border-green-500"
    | None => "border-gray-600"
    }
  );

let showSubmission = (submissions, levels) =>
  <div>
    {submissions
     |> IndexSubmission.sort
     |> Array.map(submission =>
          <Link
            href={"/submissions/" ++ (submission |> IndexSubmission.id)}
            key={submission |> IndexSubmission.id}
            ariaLabel={
              "reviewed-submission-card-" ++ (submission |> IndexSubmission.id)
            }
            className={submissionCardClasses(
              submission |> IndexSubmission.status,
            )}>
            <div className="w-full md:w-3/4">
              <div className="block text-sm md:pr-2">
                <span
                  className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
                  {submission
                   |> IndexSubmission.levelId
                   |> Level.unsafeLevelNumber(
                        levels,
                        "ShowReviewedSubmission",
                      )
                   |> str}
                </span>
                <span className="ml-2 font-semibold text-base">
                  {submission |> IndexSubmission.title |> str}
                </span>
              </div>
              <div className="mt-1 ml-px text-xs text-gray-900">
                <span> {"Submitted by " |> str} </span>
                <span className="font-semibold">
                  {submission |> IndexSubmission.userNames |> str}
                </span>
                <span className="ml-1">
                  {"on "
                   ++ (submission |> IndexSubmission.createdAtPretty)
                   |> str}
                </span>
              </div>
            </div>
            {switch (submission |> IndexSubmission.status) {
             | Some(status) =>
               <div
                 className="w-auto md:w-1/4 text-xs flex justify-end mt-2 md:mt-0">
                 {feedbackSentNotice(status |> IndexSubmission.feedbackSent)}
                 {submissionStatus(status |> IndexSubmission.failed)}
               </div>
             | None => React.null
             }}
          </Link>
        )
     |> React.array}
  </div>;

let showSubmissions = (reviewedSubmissions, levels) =>
  reviewedSubmissions |> ArrayUtils.isEmpty
    ? <div
        className="course-review__reviewed-empty text-lg font-semibold text-center py-4">
        <h5 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
          {"No Reviewed Submission" |> str}
        </h5>
        <img className="w-3/4 md:w-1/2 mx-auto mt-2" src=reviewedEmptyImage />
      </div>
    : showSubmission(reviewedSubmissions, levels);

[@react.component]
let make =
    (
      ~courseId,
      ~selectedLevel,
      ~selectedCoach,
      ~levels,
      ~reviewedSubmissions,
      ~updateReviewedSubmissionsCB,
    ) => {
  let (state, setState) = React.useState(() => Loading);
  React.useEffect2(
    () => {
      let shouldLoad =
        switch ((reviewedSubmissions: ReviewedSubmissions.t)) {
        | Unloaded => true
        | FullyLoaded(_, filter)
        | PartiallyLoaded(_, filter, _) =>
          if (filter
              |> ReviewedSubmissions.filterEq(selectedLevel, selectedCoach)) {
            false;
          } else {
            setState(_ => Reloading);
            true;
          }
        };

      shouldLoad
        ? getReviewedSubmissions(
            courseId,
            None,
            setState,
            selectedLevel,
            selectedCoach,
            [||],
            updateReviewedSubmissionsCB,
          )
        : ();

      None;
    },
    (selectedLevel, selectedCoach),
  );

  <div>
    <LoadingSpinner loading={state == Reloading} />
    {switch ((reviewedSubmissions: ReviewedSubmissions.t)) {
     | Unloaded =>
       SkeletonLoading.multiple(~count=10, ~element=SkeletonLoading.card())
     | PartiallyLoaded(reviewedSubmissions, _filter, cursor) =>
       <div>
         {showSubmissions(reviewedSubmissions, levels)}
         {state == Loading
            ? SkeletonLoading.multiple(
                ~count=3,
                ~element=SkeletonLoading.card(),
              )
            : <button
                className="btn btn-primary-ghost cursor-pointer w-full mt-8"
                onClick={_ =>
                  getReviewedSubmissions(
                    courseId,
                    Some(cursor),
                    setState,
                    selectedLevel,
                    selectedCoach,
                    reviewedSubmissions,
                    updateReviewedSubmissionsCB,
                  )
                }>
                {"Load More..." |> str}
              </button>}
       </div>
     | FullyLoaded(reviewedSubmissions, _filter) =>
       showSubmissions(reviewedSubmissions, levels)
     }}
  </div>;
};
