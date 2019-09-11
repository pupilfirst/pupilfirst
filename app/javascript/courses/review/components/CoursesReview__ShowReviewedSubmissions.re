[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

type state = {
  loading: bool,
  submissions: list(Submission.t),
  hasNextPage: bool,
  endCursor: option(string),
  level: option(Level.t),
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

let updateReviewedSubmissions = (setState, endCursor, hasNextPage, nodes) =>
  setState(state =>
    {
      ...state,
      submissions:
        state.submissions
        |> List.append(
             (
               switch (nodes) {
               | None => []
               | Some(submissionsArray) =>
                 submissionsArray
                 |> Js.Array.map(s =>
                      switch (s) {
                      | Some(submission) =>
                        let status =
                          Submission.makeStatus(
                            ~failed=submission##failed,
                            ~feedbackSent=submission##feedbackSent,
                          );
                        [
                          Submission.make(
                            ~id=submission##id,
                            ~title=submission##title,
                            ~createdAt=submission##createdAt,
                            ~levelId=submission##levelId,
                            ~userNames=submission##userNames,
                            ~targetId=submission##targetId,
                            ~status=Some(status),
                          ),
                        ];
                      | None => []
                      }
                    )
                 |> Array.to_list
               }
             )
             |> List.flatten,
           ),
      loading: false,
      endCursor,
      hasNextPage,
    }
  );

let getReviewedSubmissions =
    (authenticityToken, courseId, cursor, setState, selectedLevel, ()) => {
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
          );
       Js.Promise.resolve();
     })
  |> ignore;

  None;
};

let showSubmissionStatus = failed =>
  failed ?
    <div
      className="bg-red-100 border border-red-500 text-red-700 font-semibold px-3 py-px rounded">
      {"Failed" |> str}
    </div> :
    <div
      className="bg-green-100 border border-green-500 text-green-800 font-semibold px-3 py-px rounded">
      {"Passed" |> str}
    </div>;

let showFeedbackSent = feedbackSent =>
  feedbackSent ?
    <div
      className="bg-primary-100 text-primary-600 border border-transparent font-semibold px-3 py-px rounded mr-3">
      {"Feedback Sent" |> str}
    </div> :
    React.null;

let showLoadMoreButton =
    (authenticityToken, courseId, setState, selectedLevel, cursor) =>
  <div className="flex justify-center w-full">
    <div
      onClick={
        _ =>
          getReviewedSubmissions(
            authenticityToken,
            courseId,
            cursor,
            setState,
            selectedLevel,
            (),
          )
          |> ignore
      }>
      {"Load More" |> str}
    </div>
  </div>;

let levelNumber = (levels, levelId) =>
  "Level "
  ++ (
    levels
    |> ListUtils.unsafeFind(
         l => l |> Level.id == levelId,
         "Unable to find level with id "
         ++ levelId
         ++ "in CoursesReview__ShowPendingSubmissions",
       )
    |> Level.number
    |> string_of_int
  );

let showSubmission = (submissions, levels, setSelectedSubmission) =>
  <div>
    {
      submissions
      |> Submission.sort
      |> List.map(submission =>
           <div
             key={submission |> Submission.id}
             onClick={_ => setSelectedSubmission(_ => Some(submission))}
             className="bg-white border border-gray-300 px-6 py-5 mt-4 cursor-pointer bg-white rounded-lg shadow flex items-center justify-between hover:bg-gray-100 hover:text-primary-500 hover:shadow-md">
             <div>
               <div className="flex items-center text-sm">
                 <span
                   className="text-xs font-semibold border-r text-gray-800 pr-2 pl-0 border-gray-400">
                   {
                     submission
                     |> Submission.levelId
                     |> levelNumber(levels)
                     |> str
                   }
                 </span>
                 <span className="ml-2 font-semibold text-base">
                   {submission |> Submission.title |> str}
                 </span>
               </div>
               <div className="mt-1 text-xs text-gray-900">
                 <span> {submission |> Submission.userNames |> str} </span>
                 <span className="ml-2">
                   {
                     "Submitted on "
                     ++ (submission |> Submission.createdAtPretty)
                     |> str
                   }
                 </span>
               </div>
             </div>
             {
               switch (submission |> Submission.status) {
               | Some(status) =>
                 <div className="text-xs flex">
                   {showFeedbackSent(status |> Submission.feedbackSent)}
                   {showSubmissionStatus(status |> Submission.failed)}
                 </div>
               | None => React.null
               }
             }
           </div>
         )
      |> Array.of_list
      |> React.array
    }
  </div>;

let updateLevel = (setState, level, ()) => {
  setState(state => {...state, level, endCursor: None, submissions: []});
  None;
};

[@react.component]
let make =
    (
      ~authenticityToken,
      ~courseId,
      ~selectedLevel,
      ~levels,
      ~setSelectedSubmission,
    ) => {
  let (state, setState) =
    React.useState(() =>
      {
        loading: false,
        submissions: [],
        hasNextPage: false,
        endCursor: None,
        level: selectedLevel,
      }
    );

  React.useEffect1(updateLevel(setState, selectedLevel), [|selectedLevel|]);

  React.useEffect1(
    getReviewedSubmissions(
      authenticityToken,
      courseId,
      state.endCursor,
      setState,
      state.level,
    ),
    [|state.level|],
  );

  <div>
    {
      switch (state.submissions) {
      | [] => <div> {"No reviewed submission" |> str} </div>
      | _ => showSubmission(state.submissions, levels, setSelectedSubmission)
      }
    }
    {
      switch (state.loading, state.hasNextPage, state.endCursor) {
      | (true, _, _) => <div> {"Loading..." |> str} </div>
      | (false, false, _)
      | (false, true, None) => React.null
      | (false, true, Some(_)) =>
        showLoadMoreButton(
          authenticityToken,
          courseId,
          setState,
          state.level,
          state.endCursor,
        )
      }
    }
  </div>;
};
