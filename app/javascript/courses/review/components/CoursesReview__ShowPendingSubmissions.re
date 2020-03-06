let pendingEmptyImage: string = [%raw
  "require('../images/pending-empty.svg')"
];
open CoursesReview__Types;
let str = React.string;

let filterSubmissions = (selectedLevel, selectedCoach, submissions) => {
  let levelFiltered =
    selectedLevel
    |> OptionUtils.mapWithDefault(
         level =>
           submissions
           |> Js.Array.filter(l =>
                l |> IndexSubmission.levelId == (level |> Level.id)
              ),
         submissions,
       );

  selectedCoach
  |> OptionUtils.mapWithDefault(
       coach =>
         levelFiltered
         |> Js.Array.filter(l =>
              l |> IndexSubmission.coachIds |> Array.mem(coach |> Coach.id)
            ),
       levelFiltered,
     );
};

[@react.component]
let make = (~submissions, ~levels, ~selectedLevel, ~selectedCoach) => {
  let filteredSubmissions =
    submissions
    |> filterSubmissions(selectedLevel, selectedCoach)
    |> IndexSubmission.sort;

  <div>
    {if (filteredSubmissions |> ArrayUtils.isEmpty) {
       <div
         className="course-review__pending-empty text-lg font-semibold text-center py-4">
         <h5 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
           {"No pending submissions to review" |> str}
         </h5>
         <img className="w-3/4 md:w-1/2 mx-auto mt-2" src=pendingEmptyImage />
       </div>;
     } else {
       filteredSubmissions
       |> Array.map(indexSubmission =>
            <Link
              href={"/submissions/" ++ (indexSubmission |> IndexSubmission.id)}
              key={indexSubmission |> IndexSubmission.id}
              ariaLabel={
                "pending-submission-card-"
                ++ (indexSubmission |> IndexSubmission.id)
              }
              className="flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-l-3 border-orange-400 p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md">
              <div className="w-full md:w-3/4">
                <div className="block text-sm md:pr-2">
                  <span
                    className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
                    {indexSubmission
                     |> IndexSubmission.levelId
                     |> Level.unsafeLevelNumber(
                          levels,
                          "showPendingSubmissions",
                        )
                     |> str}
                  </span>
                  <span className="ml-2 font-semibold text-base">
                    {indexSubmission |> IndexSubmission.title |> str}
                  </span>
                </div>
                <div className="mt-1 md:ml-px text-xs text-gray-900">
                  <span> {"Submitted by " |> str} </span>
                  <span className="font-semibold">
                    {indexSubmission |> IndexSubmission.userNames |> str}
                  </span>
                  <span className="ml-1">
                    {"on "
                     ++ (indexSubmission |> IndexSubmission.createdAtPretty)
                     |> str}
                  </span>
                </div>
              </div>
              <div className="w-auto md:w-1/4 text-xs flex justify-end">
                <div
                  className="text-xs mt-2 md:mt-0 font-semibold bg-orange-100 text-orange-600 flex-shrink-0 px-2 py-px rounded">
                  {indexSubmission |> IndexSubmission.timeDistance |> str}
                </div>
              </div>
            </Link>
          )
       |> React.array;
     }}
  </div>;
};
