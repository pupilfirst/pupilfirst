[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__Root.css")|}];

open CoursesStudents__Types;

let str = React.string;

let studentAvatar = (student: TeamInfo.student) => {
  switch (student.avatarUrl) {
  | Some(avatarUrl) =>
    <img
      className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden flex-shrink-0 mt-1 md:mt-0 mr-2 md:mr-3 object-cover"
      src=avatarUrl
    />
  | None =>
    <Avatar
      name={student |> TeamInfo.studentName}
      className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden flex-shrink-0 mt-1 md:mt-0 mr-2 md:mr-3 object-cover"
    />
  };
};

let levelInfo = (levelId, levels) => {
  <span
    className="inline-flex flex-col items-center rounded bg-orange-100 border border-orange-300 px-2 pt-2 pb-1 border">
    <div className="text-xs font-semibold"> {"Level" |> str} </div>
    <div className="font-bold">
      {levels
       |> ArrayUtils.unsafeFind(
            (l: Level.t) => l.id == levelId,
            "Unable to find level with id: "
            ++ levelId
            ++ "in CoursesStudents__TeamsList",
          )
       |> Level.number
       |> string_of_int
       |> str}
    </div>
  </span>;
};

let showStudent = (team, levels, openOverlayCB) => {
  let student = TeamInfo.students(team)[0];
  <div
    key={student |> TeamInfo.studentId}
    onClick={_ => openOverlayCB()}
    ariaLabel={"student-card-" ++ (student |> TeamInfo.studentId)}
    className="flex md:flex-row justify-between bg-white mt-4 rounded-lg shadow ">
    <div className="flex flex-1 flex-col justify-center md:flex-row md:w-4/6">
      <div
        className="flex w-full items-start md:items-center p-3 md:px-4 md:py-5">
        {studentAvatar(student)}
        <div className="block text-sm md:pr-2">
          <p className="font-semibold inline-block leading-snug">
            {student |> TeamInfo.studentName |> str}
          </p>
          <p
            className="text-gray-600 font-semibold text-xs mt-px leading-snug">
            {student |> TeamInfo.studentTitle |> str}
          </p>
        </div>
      </div>
    </div>
    <div className="w-2/6 flex items-center justify-end p-3 md:p-4">
      {levelInfo(team |> TeamInfo.levelId, levels)}
    </div>
  </div>;
};

let showTeam = (team, levels, openOverlayCB) => {
  <div
    key={team |> TeamInfo.id}
    ariaLabel={"team-card-" ++ (team |> TeamInfo.id)}
    className="flex shadow bg-white rounded-lg mt-4 overflow-hidden flex-col-reverse md:flex-row">
    <div className="flex flex-col flex-1 w-full md:w-4/6">
      {team
       |> TeamInfo.students
       |> Array.map(student =>
            <div
              key={student |> TeamInfo.studentId}
              ariaLabel={"student-card-" ++ (student |> TeamInfo.studentId)}
              onClick={_ => openOverlayCB()}
              className="flex items-center bg-white">
              <div className="flex w-full md:flex-1 p-3 md:px-4 md:py-5">
                {studentAvatar(student)}
                <div className="text-sm flex flex-col">
                  <p className="font-semibold inline-block leading-snug ">
                    {student |> TeamInfo.studentName |> str}
                  </p>
                  <p
                    className="text-gray-600 font-semibold text-xs mt-px leading-snug ">
                    {student |> TeamInfo.studentTitle |> str}
                  </p>
                </div>
              </div>
            </div>
          )
       |> React.array}
    </div>
    <div
      className="flex w-full md:w-2/6 items-center bg-gray-200 md:bg-white border-l border-gray-200 p-3 md:px-4 md:py-5">
      <div className="flex-1 pb-3 md:py-3 pr-3">
        <div>
          <p
            className="text-xs bg-green-200 inline-block leading-tight px-1 py-px rounded">
            {"Team" |> str}
          </p>
          <h3 className="text-base font-semibold leading-snug">
            {team |> TeamInfo.name |> str}
          </h3>
        </div>
      </div>
      <div className="flex-shrink-0">
        {levelInfo(team |> TeamInfo.levelId, levels)}
      </div>
    </div>
  </div>;
};

let teamsList = (teams, levels, openOverlayCB) => {
  teams
  |> Array.map(team =>
       Array.length(team |> TeamInfo.students) == 1
         ? showStudent(team, levels, openOverlayCB)
         : showTeam(team, levels, openOverlayCB)
     )
  |> React.array;
};

let showTeams = (teams, levels, openOverlayCB) => {
  teams |> ArrayUtils.isEmpty
    ? <div
        className="course-review__reviewed-empty text-lg font-semibold text-center py-4">
        <h5 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
          {"No teams to show" |> str}
        </h5>
      </div>
    : teamsList(teams, levels, openOverlayCB);
};

[@react.component]
let make = (~levels, ~teams, ~openOverlayCB) => {
  <div> {showTeams(teams, levels, openOverlayCB)} </div>;
};
