[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

let showUsers = (users, userIds) =>
  users
  |> List.filter(user => userIds |> List.mem(user |> User.id))
  |> List.map(u => u |> User.name)
  |> String.concat(", ");

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

[@react.component]
let make =
    (~authenticityToken, ~pendingSubmissions, ~users, ~levels, ~selectedLevel) => {
  let submissionToShow =
    switch (selectedLevel) {
    | None => pendingSubmissions
    | Some(level) =>
      pendingSubmissions
      |> List.filter(l =>
           l |> PendingSubmission.levelId == (level |> Level.id)
         )
    };
  <div>
    {
      submissionToShow
      |> List.map(submission =>
           <div
             key={submission |> PendingSubmission.id}
             className="bg-white border-t p-6 flex items-center justify-between hover:bg-gray-200 hover:text-primary-500 cursor-pointer bg-white text-center rounded-lg shadow-md mt-2">
             <div>
               <div className="flex items-center text-sm">
                 <span
                   className="bg-gray-400 py-px px-2 rounded-lg font-semibold">
                   {
                     submission
                     |> PendingSubmission.levelId
                     |> levelNumber(levels)
                     |> str
                   }
                 </span>
                 <span className="ml-2 font-semibold">
                   {submission |> PendingSubmission.title |> str}
                 </span>
               </div>
               <div className="text-left mt-1 text-xs text-gray-600">
                 <span>
                   {
                     submission
                     |> PendingSubmission.userIds
                     |> showUsers(users)
                     |> str
                   }
                 </span>
                 <span className="ml-2">
                   {
                     "Submitted on "
                     ++ (submission |> PendingSubmission.createdAtPretty)
                     |> str
                   }
                 </span>
               </div>
             </div>
             <div className="text-xs">
               {submission |> PendingSubmission.timeDistance |> str}
             </div>
           </div>
         )
      |> Array.of_list
      |> React.array
    }
  </div>;
};
