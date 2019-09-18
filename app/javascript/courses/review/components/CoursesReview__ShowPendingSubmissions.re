[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__SubmissionOverlay.css")|}];

open CoursesReview__Types;
let str = React.string;

[@react.component]
let make =
    (
      ~authenticityToken,
      ~submissions,
      ~levels,
      ~selectedLevel,
      ~setSelectedSubmission,
    ) => {
  let submissionToShow =
    switch (selectedLevel) {
    | None => submissions
    | Some(level) =>
      submissions
      |> Js.Array.filter(l => l |> Submission.levelId == (level |> Level.id))
    };
  <div>
    {
      submissionToShow
      |> Array.map(submission =>
           <div
             key={submission |> Submission.id}
             onClick={_ => setSelectedSubmission(_ => Some(submission))}
             className="flex flex-col md:flex-row items-start md:items-center justify-between bg-white border border-gray-300 p-3 md:p-6 mt-4 cursor-pointer rounded-lg shadow hover:bg-gray-100 hover:text-primary-500 hover:shadow-md">
             <div className="md:pr-2">
               <div className="block md:flex md:items-center text-sm">
                 <span
                   className="inline-block bg-gray-300 text-xs font-semibold mr-2 px-2 py-px rounded">
                   {
                     submission
                     |> Submission.levelId
                     |> Level.unsafeLevelNumber(
                          levels,
                          "showPendingSubmissions",
                        )
                     |> str
                   }
                 </span>
                 <span
                   className="inline-block md:block font-semibold text-base">
                   {submission |> Submission.title |> str}
                 </span>
               </div>
               <div className="mt-1 md:ml-px text-xs text-gray-900">
                 <span> {"Submitted by " |> str} </span>
                 <span className="font-semibold">
                   {submission |> Submission.userNames |> str}
                 </span>
                 <span className="ml-1">
                   {"on " ++ (submission |> Submission.createdAtPretty) |> str}
                 </span>
               </div>
             </div>
             <div
               className="text-xs mt-1 md:mt-0 font-semibold bg-orange-100 text-orange-600 flex-shrink-0 px-2 py-px rounded">
               {submission |> Submission.timeDistance |> str}
             </div>
           </div>
         )
      |> React.array
    }
  </div>;
};
