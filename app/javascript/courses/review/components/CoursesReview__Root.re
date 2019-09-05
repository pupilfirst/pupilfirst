[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

let showUsers = (users, userIds) =>
  users
  |> List.filter(user => userIds |> List.mem(user |> User.id))
  |> List.map(u => u |> User.name)
  |> String.concat(", ");

[@react.component]
let make = (~authenticityToken, ~levels, ~submissions, ~users) =>
  <div className="bg-gray-100 py-8">
    <div className="max-w-3xl mx-auto">
      <div className="flex justify-between">
        <div className="rounded-lg border overflow-hidden">
          <button className="bg-gray-500 py-2 px-6">
            {"Pending" |> str}
          </button>
          <button className="bg-white py-2 px-6"> {"Reviewed" |> str} </button>
        </div>
        <div>
          <button className="bg-white p-2"> {"Filter" |> str} </button>
        </div>
      </div>
      {
        submissions
        |> Array.map(submission =>
             <div
               className="bg-white border-t p-6 flex items-center justify-between hover:bg-gray-200 hover:text-primary-500 cursor-pointer bg-white text-center rounded-lg shadow-md mt-2">
               <div>
                 <div className="flex items-center">
                   <span
                     className="bg-gray-400 py-1 px-2 rounded-lg font-semibold">
                     {"Level 1" |> str}
                   </span>
                   <span className="ml-2 text-lg font-semibold">
                     {submission |> Submission.title |> str}
                   </span>
                 </div>
                 <div className="text-left mt-1 text-sm text-gray-600">
                   <span>
                     {
                       submission
                       |> Submission.userIds
                       |> showUsers(users)
                       |> str
                     }
                   </span>
                   <span className="ml-2">
                     {submission |> Submission.createdAtPretty |> str}
                   </span>
                 </div>
               </div>
               <div> {"12 days ago" |> str} </div>
             </div>
           )
        |> React.array
      }
    </div>
  </div>;
