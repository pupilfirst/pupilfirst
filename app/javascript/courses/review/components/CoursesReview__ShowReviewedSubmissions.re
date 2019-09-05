[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

type status =
  | Loading
  | Loaded(list(ReviewedSubmission.t));

module ReviewedSubmissionsQuery = [%graphql
  {|
    query($courseId: ID!, $page: Int! ) {
      reviewedSubmissions(courseId: $courseId, page: $page) {
        id,title,userNames,failed,feedbackSent,levelId,createdAt
      }
  }
|}
];

let updateReviewedSubmissions = (setStatus, submissions) => {
  let reviewedSubmissions =
    submissions
    |> Js.Array.map(submission =>
         ReviewedSubmission.make(
           ~id=submission##id,
           ~title=submission##title,
           ~createdAt=submission##createdAt,
           ~levelId=submission##levelId,
           ~userNames=submission##userNames,
           ~failed=submission##failed,
           ~feedbackSent=submission##feedbackSent,
         )
       )
    |> Array.to_list;
  setStatus(_ => Loaded(reviewedSubmissions));
};

let getReviewedSubmissions =
    (authenticityToken, courseId, setStatus, page, ()) => {
  setStatus(_ => Loading);
  ReviewedSubmissionsQuery.make(~courseId, ~page, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##reviewedSubmissions |> updateReviewedSubmissions(setStatus);
       Js.Promise.resolve();
     })
  |> ignore;

  None;
};

let showPassed = passed =>
  passed ?
    <div className="bg-green-400 px-2 py-1 rounded shadow">
      {"Passed" |> str}
    </div> :
    <div className="bg-red-400 px-2 py-1 rounded shadow">
      {"Failed" |> str}
    </div>;

let showFeedbackSent = feedbackSent =>
  feedbackSent ?
    <div className="bg-primary-200 px-2 py-1 rounded shadow mr-1">
      {"Feedback Sent" |> str}
    </div> :
    React.null;

let showNextButton = (page, setPage) =>
  <div onClick={_ => setPage(_ => page + 1)}> {"Next" |> str} </div>;

let showPreviousButton = (page, setPage) =>
  page <= 1 ?
    React.null :
    <div onClick={_ => setPage(_ => page - 1)}> {"Previous" |> str} </div>;

let showSubmission = (submissions, page, setPage) =>
  <div>
    {
      submissions
      |> List.map(submission =>
           <div
             key={submission |> ReviewedSubmission.id}
             className="bg-white border-t p-6 flex items-center justify-between hover:bg-gray-200 hover:text-primary-500 cursor-pointer bg-white text-center rounded-lg shadow-md mt-2">
             <div>
               <div className="flex items-center text-sm">
                 <span
                   className="bg-gray-400 py-px px-2 rounded-lg font-semibold">
                   {"Level 1" |> str}
                 </span>
                 <span className="ml-2 font-semibold">
                   {submission |> ReviewedSubmission.title |> str}
                 </span>
               </div>
               <div className="text-left mt-1 text-xs text-gray-600">
                 <span>
                   {submission |> ReviewedSubmission.userNames |> str}
                 </span>
                 <span className="ml-2">
                   {
                     "Submitted on "
                     ++ (submission |> ReviewedSubmission.createdAtPretty)
                     |> str
                   }
                 </span>
               </div>
             </div>
             <div className="text-xs flex">
               {
                 showFeedbackSent(
                   submission |> ReviewedSubmission.feedbackSent,
                 )
               }
               {showPassed(submission |> ReviewedSubmission.failed)}
             </div>
           </div>
         )
      |> Array.of_list
      |> React.array
    }
    <div className="flex items-center w-full">
      {showPreviousButton(page, setPage)}
      {showNextButton(page, setPage)}
    </div>
  </div>;

[@react.component]
let make = (~authenticityToken, ~courseId) => {
  let (page, setPage) = React.useState(() => 1);
  let (status, setStatus) = React.useState(() => Loading);

  React.useEffect1(
    getReviewedSubmissions(authenticityToken, courseId, setStatus, page),
    [|page|],
  );

  <div>
    {
      switch (status) {
      | Loading => <div> {"Loading..." |> str} </div>
      | Loaded(submissions) =>
        switch (submissions, page) {
        | ([], 1) => <div> {"No reviewed submission" |> str} </div>
        | ([], _) =>
          <div>
            {"Nothing more to load" |> str}
            {showPreviousButton(page, setPage)}
          </div>
        | (_, _) => showSubmission(submissions, page, setPage)
        }
      }
    }
  </div>;
};
