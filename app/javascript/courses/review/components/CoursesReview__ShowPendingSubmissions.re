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
             className="flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-l-3 border-orange-400 p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md">
             <div className="w-full md:w-3/4">
               <div className="block text-sm md:pr-2">
                 <span
                   className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
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
                 <span className="ml-2 font-semibold text-base">
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
             <div className="w-auto md:w-1/4 text-xs flex justify-end">
               <div
                 className="text-xs mt-2 md:mt-0 font-semibold bg-orange-100 text-orange-600 flex-shrink-0 px-2 py-px rounded">
                 {submission |> Submission.timeDistance |> str}
               </div>
             </div>
           </div>
         )
      |> React.array
    }
  </div>;
};