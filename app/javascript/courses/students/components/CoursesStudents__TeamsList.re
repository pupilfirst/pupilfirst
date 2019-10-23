[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__Root.css")|}];

open CoursesStudents__Types;

let str = React.string;

module TeamsQuery = [%graphql
  {|
    query($courseId: ID!, $levelId: ID, $after: String) {
      teams(courseId: $courseId, levelId: $levelId, first: 20, after: $after) {
        nodes {
        id,
        name,
        levelId,
        students {
          id,
          name
          title
          avatarUrl
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
      teams,
      updateTeamsCB,
    ) => {
  setLoading(_ => true);
  (
    switch (selectedLevel, cursor) {
    | (Some(level), Some(cursor)) =>
      TeamsQuery.make(
        ~courseId,
        ~levelId=level |> Level.id,
        ~after=cursor,
        (),
      )
    | (Some(level), None) =>
      TeamsQuery.make(~courseId, ~levelId=level |> Level.id, ())
    | (None, Some(cursor)) => TeamsQuery.make(~courseId, ~after=cursor, ())
    | (None, None) => TeamsQuery.make(~courseId, ())
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
    <img className="w-10 h-10 rounded-full mr-4 object-cover" src=avatarUrl />
  | None =>
    <Avatar
      name={student |> TeamInfo.studentName}
      className="w-10 h-10 mr-4"
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
    className="flex md:flex-row items-start md:items-center justify-between bg-white p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:shadow-md">
    {studentAvatar(student)}
    <div className="w-full w-5/6 md:w-3/4">
      <div className="block text-sm md:pr-2">
        <p className="text-black font-semibold inline-block">
          {student |> TeamInfo.studentName |> str}
        </p>
        <p className="text-gray-600 font-semibold text-xs mt-px">
          {student |> TeamInfo.studentTitle |> str}
        </p>
      </div>
    </div>
    <div className="w-1/6 text-center">
      {levelInfo(team |> TeamInfo.levelId, levels)}
    </div>
  </div>;
};

let showTeam = (team, levels, openOverlayCB) => {
  <div
    key={team |> TeamInfo.id}
    ariaLabel={"team-card-" ++ (team |> TeamInfo.id)}
    className="flex shadow bg-white rounded-lg mt-4 overflow-hidden">
    <div className="flex flex-col flex-1 w-3/5">
      {team
       |> TeamInfo.students
       |> Array.map(student =>
            <div
              key={student |> TeamInfo.studentId}
              ariaLabel={"student-card-" ++ (student |> TeamInfo.studentId)}
              onClick={_ => openOverlayCB()}
              className="h-full cursor-pointer flex items-center bg-white">
              <div className="flex flex-1 w-3/5 h-full">
                <div className="flex items-center w-full">
                  <div
                    className="flex flex-1 self-stretch items-center py-4 px-4 hover:bg-gray-100">
                    {studentAvatar(student)}
                    <div className="text-sm flex flex-col">
                      <p className="text-black font-semibold inline-block ">
                        {student |> TeamInfo.studentName |> str}
                      </p>
                      <p className="text-gray-600 font-semibold text-xs mt-px">
                        {student |> TeamInfo.studentTitle |> str}
                      </p>
                      <div className="flex flex-wrap" />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )
       |> React.array}
    </div>
    <div className="flex w-2/5 items-center">
      <div className="w-3/5 py-4 px-3">
        <div className="students-team--name mb-5">
          <p className="text-xs"> {"Team Name" |> str} </p>
          <h5> {team |> TeamInfo.name |> str} </h5>
        </div>
      </div>
      <div className="w-2/5 text-center">
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
let make =
    (
      ~levels,
      ~selectedLevel,
      ~teams,
      ~courseId,
      ~updateTeamsCB,
      ~openOverlayCB,
    ) => {
  let (loading, setLoading) = React.useState(() => false);
  React.useEffect1(
    () => {
      switch ((teams: Teams.t)) {
      | Unloaded =>
        getTeams(
          AuthenticityToken.fromHead(),
          courseId,
          None,
          setLoading,
          selectedLevel,
          [||],
          updateTeamsCB,
        )
      | FullyLoaded(_)
      | PartiallyLoaded(_, _) => ()
      };
      None;
    },
    [|selectedLevel|],
  );

  <div>
    {switch (teams) {
     | Unloaded =>
       SkeletonLoading.multiple(~count=10, ~element=SkeletonLoading.card())
     | PartiallyLoaded(teams, cursor) =>
       <div>
         {showTeams(teams, levels, openOverlayCB)}
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
                    teams,
                    updateTeamsCB,
                  )
                }>
                {"Load More..." |> str}
              </button>}
       </div>
     | FullyLoaded(teams) => showTeams(teams, levels, openOverlayCB)
     }}
  </div>;
};
