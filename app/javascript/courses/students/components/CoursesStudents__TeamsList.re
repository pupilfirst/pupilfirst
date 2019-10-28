[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__Root.css")|}];

open CoursesStudents__Types;

let str = React.string;

module TeamsQuery = [%graphql
  {|
    query($courseId: ID!, $levelId: ID, $search: String, $after: String) {
      teams(courseId: $courseId, levelId: $levelId, search: $search, first: 20, after: $after) {
        nodes {
        id,
        name,
        levelId,
        students {
          id,
          name
          title
          avatarUrl
          targetsCompleted
        }
        }
        pageInfo{
          endCursor,hasNextPage
        }
      }
  }
|}
];

let updateTeamInfo =
    (setLoading, endCursor, hasNextPage, teams, updateTeamsCB, nodes) => {
  updateTeamsCB(
    ~teams=
      (
        switch (nodes) {
        | None => [||]
        | Some(teamsArray) => teamsArray |> TeamInfo.decodeJS
        }
      )
      |> Array.to_list
      |> List.flatten
      |> Array.of_list
      |> Array.append(teams),
    ~hasNextPage,
    ~endCursor,
  );
  setLoading(_ => false);
};

let getTeams =
    (
      authenticityToken,
      courseId,
      cursor,
      setLoading,
      selectedLevel,
      search,
      teams,
      updateTeamsCB,
    ) => {
  setLoading(_ => true);
  (
    switch (selectedLevel, search, cursor) {
    | (Some(level), Some(search), Some(cursor)) =>
      TeamsQuery.make(
        ~courseId,
        ~levelId=level |> Level.id,
        ~search,
        ~after=cursor,
        (),
      )
    | (Some(level), Some(search), None) =>
      TeamsQuery.make(~courseId, ~levelId=level |> Level.id, ~search, ())
    | (None, Some(search), Some(cursor)) =>
      TeamsQuery.make(~courseId, ~search, ~after=cursor, ())
    | (Some(level), None, Some(cursor)) =>
      TeamsQuery.make(
        ~courseId,
        ~levelId=level |> Level.id,
        ~after=cursor,
        (),
      )
    | (Some(level), None, None) =>
      TeamsQuery.make(~courseId, ~levelId=level |> Level.id, ())
    | (None, Some(search), None) => TeamsQuery.make(~courseId, ~search, ())
    | (None, None, Some(cursor)) =>
      TeamsQuery.make(~courseId, ~after=cursor, ())
    | (None, None, None) => TeamsQuery.make(~courseId, ())
    }
  )
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##teams##nodes
       |> updateTeamInfo(
            setLoading,
            response##teams##pageInfo##endCursor,
            response##teams##pageInfo##hasNextPage,
            teams,
            updateTeamsCB,
          );
       Js.Promise.resolve();
     })
  |> ignore;
};

let studentAvatar = (student: TeamInfo.student) => {
  switch (student.avatarUrl) {
  | Some(avatarUrl) =>
    <img
      className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden flex-shrink-0 mr-2 md:mr-3 object-cover"
      src=avatarUrl
    />
  | None =>
    <Avatar
      name={student |> TeamInfo.studentName}
      className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden flex-shrink-0 mr-2 md:mr-3 object-cover"
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

let studentProgressPercentage = (student, course) => {
  let test =
    (
      (TeamInfo.targetsCompleted(student) |> float_of_int)
      /. (Course.totalTargets(course) |> float_of_int)
      *. 100.0
      |> int_of_float
      |> string_of_int
    )
    ++ "%";
  Js.log(test);
  test;
};

let showStudent = (team, levels, course, openOverlayCB) => {
  let student = TeamInfo.students(team)[0];
  <div
    key={student |> TeamInfo.studentId}
    onClick={_ => openOverlayCB()}
    ariaLabel={"student-card-" ++ (student |> TeamInfo.studentId)}
    className="flex md:flex-row justify-between bg-white mt-4 cursor-pointer rounded-lg shadow hover:shadow-md">
    <div className="flex flex-1 flex-col md:flex-row md:w-4/6">
      <div
        className="md:w-1/2 flex items-center p-3 pr-0 pb-2 md:px-4 md:py-5">
        {studentAvatar(student)}
        <div className="block text-sm md:pr-2">
          <p className="font-semibold inline-block leading-snug">
            {student |> TeamInfo.studentName |> str}
          </p>
          <p
            className="text-gray-600 font-semibold text-xs mt-px leading-snug w-42 truncate">
            {student |> TeamInfo.studentTitle |> str}
          </p>
        </div>
      </div>
      <div
        className="md:w-1/2 flex flex-col ml-11 md:ml-0 p-3 pr-0 pt-0 md:px-4 md:py-5 justify-center">
        <p className="text-xs leading-tight text-gray-700">
          {"Course Progress:" |> str}
          <span className="font-semibold text-gray-900 ml-1">
            {studentProgressPercentage(student, course) |> str}
          </span>
        </p>
        <div
          className="w-full h-1 md:h-2 bg-gray-300 rounded-lg overflow-hidden mt-1">
          <div
            className="bg-green-500 text-xs leading-none h-1 md:h-2 w-30"
            style={ReactDOMRe.Style.make(
              ~width={studentProgressPercentage(student, course)},
              (),
            )}
          />
        </div>
      </div>
    </div>
    <div className="w-2/6 flex items-center justify-end p-3 md:p-4">
      {levelInfo(team |> TeamInfo.levelId, levels)}
    </div>
  </div>;
};

let showTeam = (team, levels, course, openOverlayCB) => {
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
              className="cursor-pointer hover:bg-gray-100 flex items-center bg-white">
              <div className="flex w-full md:flex-1">
                <div className="flex w-full">
                  <div className="w-1/2 flex items-center p-3 md:px-4 md:py-5">
                    {studentAvatar(student)}
                    <div className="text-sm flex flex-col">
                      <p className="font-semibold inline-block leading-snug ">
                        {student |> TeamInfo.studentName |> str}
                      </p>
                      <p
                        className="text-gray-600 font-semibold text-xs mt-px leading-snug w-24 md:w-42 truncate">
                        {student |> TeamInfo.studentTitle |> str}
                      </p>
                      <div className="flex flex-wrap" />
                    </div>
                  </div>
                  <div
                    className="w-1/2 flex flex-col p-3 md:px-4 md:py-5 justify-center">
                    <p className="text-xs leading-tight text-gray-700">
                      {"Course Progress:" |> str}
                      <span className="font-semibold text-gray-900 ml-1">
                        {studentProgressPercentage(student, course) |> str}
                      </span>
                    </p>
                    <div
                      className="w-full h-1 md:h-2 bg-gray-300 rounded-lg overflow-hidden mt-1">
                      <div
                        className="bg-green-500 text-xs leading-none h-1 md:h-2 w-30"
                        style={ReactDOMRe.Style.make(
                          ~width={studentProgressPercentage(student, course)},
                          (),
                        )}
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )
       |> React.array}
    </div>
    <div
      className="flex w-full md:w-2/6 items-center border-l border-gray-200 p-3 md:px-4 md:py-5">
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

let teamsList = (teams, levels, course, openOverlayCB) => {
  teams
  |> Array.map(team =>
       Array.length(team |> TeamInfo.students) == 1
         ? showStudent(team, levels, course, openOverlayCB)
         : showTeam(team, levels, course, openOverlayCB)
     )
  |> React.array;
};

let showTeams = (teams, levels, course, openOverlayCB) => {
  teams |> ArrayUtils.isEmpty
    ? <div
        className="course-review__reviewed-empty text-lg font-semibold text-center py-4">
        <h5 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
          {"No teams to show" |> str}
        </h5>
      </div>
    : teamsList(teams, levels, course, openOverlayCB);
};

[@react.component]
let make =
    (
      ~levels,
      ~selectedLevel,
      ~studentSearch,
      ~teams,
      ~course,
      ~updateTeamsCB,
      ~openOverlayCB,
    ) => {
  let (loading, setLoading) = React.useState(() => false);
  let courseId = course |> Course.id;
  React.useEffect2(
    () => {
      switch ((teams: Teams.t)) {
      | Unloaded =>
        getTeams(
          AuthenticityToken.fromHead(),
          courseId,
          None,
          setLoading,
          selectedLevel,
          studentSearch,
          [||],
          updateTeamsCB,
        )
      | FullyLoaded(_)
      | PartiallyLoaded(_, _) => ()
      };
      None;
    },
    (selectedLevel, studentSearch),
  );

  <div>
    {switch (teams) {
     | Unloaded =>
       SkeletonLoading.multiple(~count=10, ~element=SkeletonLoading.card())
     | PartiallyLoaded(teams, cursor) =>
       <div>
         {showTeams(teams, levels, course, openOverlayCB)}
         {loading
            ? SkeletonLoading.multiple(
                ~count=3,
                ~element=SkeletonLoading.card(),
              )
            : <button
                className="btn btn-primary-ghost cursor-pointer w-full mt-8"
                onClick={_ =>
                  getTeams(
                    AuthenticityToken.fromHead(),
                    courseId,
                    Some(cursor),
                    setLoading,
                    selectedLevel,
                    studentSearch,
                    teams,
                    updateTeamsCB,
                  )
                }>
                {"Load More..." |> str}
              </button>}
       </div>
     | FullyLoaded(teams) => showTeams(teams, levels, course, openOverlayCB)
     }}
  </div>;
};
