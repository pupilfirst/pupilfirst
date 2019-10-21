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

let teamsList = (teams, levels, openOverlayCB) => {
  teams
  |> Array.map(team =>
       <div
         key={team |> CoursesStudents__TeamInfo.id}
         onClick={_ => openOverlayCB}
         ariaLabel={"team-card-" ++ (team |> CoursesStudents__TeamInfo.id)}
         className="flex flex-col md:flex-row items-start md:items-center justify-between bg-white p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:shadow-md">
         <div className="w-full md:w-3/4">
           <div className="block text-sm md:pr-2">
             <span
               className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
               {team |> CoursesStudents__TeamInfo.name |> str}
             </span>
           </div>
         </div>
       </div>
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
