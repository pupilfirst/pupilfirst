[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

type state = {
  loading: bool,
  submissions: array(Submission.t),
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
        |> Array.append(
             (
               switch (nodes) {
               | None => [||]
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
               }
             )
             |> Array.to_list |> List.flatten |> Array.of_list,
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
      className="bg-red-100 border border-red-500 leading-normal text-red-800 font-semibold px-3 py-px rounded">
      {"Failed" |> str}
    </div> :
    <div
      className="bg-green-100 border border-green-500 leading-normal text-green-800 font-semibold px-3 py-px rounded">
      {"Passed" |> str}
    </div>;

let showFeedbackSent = feedbackSent =>
  feedbackSent ?
    <div
      className="bg-primary-100 text-primary-600 border border-transparent leading-normal font-semibold px-3 py-px rounded mr-3">
      {"Feedback Sent" |> str}
    </div> :
    React.null;

let showLoadMoreButton =
    (authenticityToken, courseId, setState, selectedLevel, cursor) =>
  <div className="flex justify-center w-full">
    <div
      className="btn border mt-4 bg-white cursor-pointer"
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

let showSubmission = (submissions, levels, setSelectedSubmission) =>
  <div>
    {
      submissions
      |> Submission.sort
      |> Array.map(submission =>
           <div
             key={submission |> Submission.id}
             onClick={_ => setSelectedSubmission(_ => Some(submission))}
             className="flex flex-col md:flex-row items-start md:items-center justify-between bg-white border border-gray-300 p-3 md:p-6 mt-4 cursor-pointer rounded-lg shadow hover:bg-gray-100 hover:text-primary-500 hover:shadow-md">
             <div className="md:pr-2">
               <div className="block md:flex md:items-center text-sm">
                 <span
                   className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
                   {
                     submission
                     |> Submission.levelId
                     |> Level.unsafeLevelNumber(levels, "ShowReviewedSubmission")
                     |> str
                   }
                 </span>
                 <span className="ml-2 font-semibold text-base">
                   {submission |> Submission.title |> str}
                 </span>
               </div>
               <div className="mt-1 ml-px text-xs text-gray-900">
                 <span> {"Submitted by " |> str} </span>
                 <span className="font-semibold">
                   {submission |> Submission.userNames |> str}
                 </span>
                 <span className="ml-1">
                   {"on " ++ (submission |> Submission.createdAtPretty) |> str}
                 </span>
               </div>
             </div>
             {
               switch (submission |> Submission.status) {
               | Some(status) =>
                 <div className="text-xs flex mt-2 md:mt-0">
                   {showFeedbackSent(status |> Submission.feedbackSent)}
                   {showSubmissionStatus(status |> Submission.failed)}
                 </div>
               | None => React.null
               }
             }
           </div>
         )

      |> React.array
    }
  </div>;

let updateLevel = (setState, level, ()) => {
  setState(state => {...state, level, endCursor: None, submissions: [||]});
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
        submissions: [||],
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
      | [||] => <div> {"No reviewed submission" |> str} </div>
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
