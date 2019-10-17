[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__Root.css")|}];

open CoursesStudents__Types;

let str = React.string;

[@react.component]
let make = (~levels, ~selectedLevel, ~teams) => {
  let filteredTeams =
    switch (selectedLevel) {
    | None => teams
    | Some(level) =>
      teams
      |> Js.Array.filter(team => level |> Level.id == (team |> Team.levelId))
    };

  <div>
    {switch (filteredTeams) {
     | [||] =>
       <div
         className="course-review__pending-empty text-lg font-semibold text-center py-4">
         <h5 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
           {"No students in this level" |> str}
         </h5>
       </div>
     | _ =>
       filteredTeams
       |> Array.map(team =>
            <div
              key={team |> Team.id}
              ariaLabel={"team-card-" ++ (team |> Team.id)}
              className="flex flex-col md:flex-row items-start md:items-center justify-between bg-white p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:shadow-md">
              <div className="w-full md:w-3/4">
                <div className="block text-sm md:pr-2">
                  <span
                    className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
                    {team
                     |> Team.levelId
                     |> Level.unsafeLevelNumber(levels, "studentsList")
                     |> str}
                  </span>
                </div>
              </div>
            </div>
          )
       |> React.array
     }}
  </div>;
};
