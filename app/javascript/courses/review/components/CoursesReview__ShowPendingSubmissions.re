[@bs.config {jsx: 3}];

let pendingEmptyImage: string = [%raw
  "require('../images/pending-empty.svg')"
];
open CoursesReview__Types;
let str = React.string;

[@react.component]
let make = (~submissions, ~levels, ~selectedLevel, ~openOverlayCB) => {
  let submissionToShow =
    switch (selectedLevel) {
    | None => submissions
    | Some(level) =>
      submissions
      |> Js.Array.filter(l =>
           l |> SubmissionInfo.levelId == (level |> Level.id)
         )
    };
  <div>
    {switch (submissionToShow) {
     | [||] =>
       <div
         className="course-review__pending-empty text-lg font-semibold text-center py-4">
         <h5 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
           {"No pending submissions to review" |> str}
         </h5>
         <img className="w-3/4 md:w-1/2 mx-auto mt-2" src=pendingEmptyImage />
       </div>
     | _ =>
       submissionToShow
       |> Array.map(submission =>
            <div
              key={submission |> SubmissionInfo.id}
              ariaLabel={
                "pending-submission-card-" ++ (submission |> SubmissionInfo.id)
              }
              onClick={_ => openOverlayCB(submission |> SubmissionInfo.id)}
              className="flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-l-3 border-orange-400 p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md">
              <div className="w-full md:w-3/4">
                <div className="block text-sm md:pr-2">
                  <span
                    className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
                    {submission
                     |> SubmissionInfo.levelId
                     |> Level.unsafeLevelNumber(
                          levels,
                          "showPendingSubmissions",
                        )
                     |> str}
                  </span>
                  <span className="ml-2 font-semibold text-base">
                    {submission |> SubmissionInfo.title |> str}
                  </span>
                </div>
                <div className="mt-1 md:ml-px text-xs text-gray-900">
                  <span> {"Submitted by " |> str} </span>
                  <span className="font-semibold">
                    {submission |> SubmissionInfo.userNames |> str}
                  </span>
                  <span className="ml-1">
                    {"on "
                     ++ (submission |> SubmissionInfo.createdAtPretty)
                     |> str}
                  </span>
                </div>
              </div>
              <div className="w-auto md:w-1/4 text-xs flex justify-end">
                <div
                  className="text-xs mt-2 md:mt-0 font-semibold bg-orange-100 text-orange-600 flex-shrink-0 px-2 py-px rounded">
                  {submission |> SubmissionInfo.timeDistance |> str}
                </div>
              </div>
            </div>
          )
       |> React.array
     }}
  </div>;
};
