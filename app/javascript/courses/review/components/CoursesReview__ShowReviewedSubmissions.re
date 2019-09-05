[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

module ReviewedSubmissionsQuery = [%graphql
  {|
    query($courseId: ID!, $page: Int! ) {
      reviewedSubmissions(courseId: $courseId, page: $page) {
        id,title,userNames,failed,feedbackSent,levelId,createdAt
      }
  }
|}
];

let updateReviewedSubmissions = (setReviewedSubmissions, submissions) => {
  let reviewedSubmissions =
    submissions
    |> Js.Array.map(submission =>
         RevieweredSubmission.make(
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
  setReviewedSubmissions(_ => reviewedSubmissions);
};

let getReviewedSubmissions =
    (authenticityToken, courseId, setReviewedSubmissions, page, ()) => {
  ReviewedSubmissionsQuery.make(~courseId, ~page, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##reviewedSubmissions
       |> updateReviewedSubmissions(setReviewedSubmissions);
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

[@react.component]
let make = (~authenticityToken, ~courseId) => {
  let (page, setPage) = React.useState(() => 1);
  let (reviewedSubmissions, setReviewedSubmissions) =
    React.useState(() => []);

  React.useEffect1(
    getReviewedSubmissions(
      authenticityToken,
      courseId,
      setReviewedSubmissions,
      page,
    ),
    [|page|],
  );

  <div>
    {
      reviewedSubmissions
      |> List.map(submission =>
           <div
             key={submission |> RevieweredSubmission.id}
             className="bg-white border-t p-6 flex items-center justify-between hover:bg-gray-200 hover:text-primary-500 cursor-pointer bg-white text-center rounded-lg shadow-md mt-2">
             <div>
               <div className="flex items-center text-sm">
                 <span
                   className="bg-gray-400 py-px px-2 rounded-lg font-semibold">
                   {"Level 1" |> str}
                 </span>
                 <span className="ml-2 font-semibold">
                   {submission |> RevieweredSubmission.title |> str}
                 </span>
               </div>
               <div className="text-left mt-1 text-xs text-gray-600">
                 <span>
                   {submission |> RevieweredSubmission.userNames |> str}
                 </span>
                 <span className="ml-2">
                   {
                     "Submitted on "
                     ++ (submission |> RevieweredSubmission.createdAtPretty)
                     |> str
                   }
                 </span>
               </div>
             </div>
             <div className="text-xs flex">
               {
                 showFeedbackSent(
                   submission |> RevieweredSubmission.feedbackSent,
                 )
               }
               {showPassed(submission |> RevieweredSubmission.failed)}
             </div>
           </div>
         )
      |> Array.of_list
      |> React.array
    }
  </div>;
};
