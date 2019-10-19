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
      teams
      |> Array.append(
           (
             switch (nodes) {
             | None => [||]
             | Some(teamsArray) => teamsArray |> TeamInfo.decodeJS
             }
           )
           |> Array.to_list
           |> List.flatten
           |> Array.of_list,
         ),
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
  Js.log(selectedLevel);
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

[@react.component]
let make = (~levels, ~selectedLevel, ~teams, ~courseId, ~updateTeamsCB) => {
  let (loading, setLoading) = React.useState(() => false);
  React.useEffect1(
    () => {
      Js.log(teams);
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
    {switch ((teams: Teams.t)) {
     | Unloaded =>
       SkeletonLoading.multiple(~count=10, ~element=SkeletonLoading.card())
     | PartiallyLoaded(teams, cursor) =>
       teams
       |> Array.map(team =>
            <div
              key={team |> TeamInfo.id}
              ariaLabel={"team-card-" ++ (team |> TeamInfo.id)}
              className="flex flex-col md:flex-row items-start md:items-center justify-between bg-white p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:shadow-md">
              <div className="w-full md:w-3/4">
                <div className="block text-sm md:pr-2">
                  <span
                    className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
                    {team
                     |> TeamInfo.levelId
                     |> Level.unsafeLevelNumber(levels, "studentsList")
                     |> str}
                  </span>
                </div>
              </div>
            </div>
          )
       |> React.array
     | FullyLoaded(teams) =>
       teams
       |> Array.map(team =>
            <div
              key={team |> CoursesStudents__TeamInfo.id}
              ariaLabel={
                "team-card-" ++ (team |> CoursesStudents__TeamInfo.id)
              }
              className="flex flex-col md:flex-row items-start md:items-center justify-between bg-white p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:shadow-md">
              <div className="w-full md:w-3/4">
                <div className="block text-sm md:pr-2">
                  <span
                    className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
                    {team
                     |> CoursesStudents__TeamInfo.levelId
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
