[@bs.config {jsx: 3}];

let str = React.string;

open StudentsEditor__Types;

module CourseTeamsQuery = [%graphql
  {|
    query($courseId: ID!, $levelId: ID, $search: String, $after: String, $tags: [String!]) {
      courseTeams(courseId: $courseId, levelId: $levelId, search: $search, first: 20, after: $after, tags: $tags) {
        nodes {
        id,
        name,
        levelId,
        coachIds,
        levelId,
        accessEndsAt
        students {
          id,
          name,
          title,
          avatarUrl,
          email, tags, excludedFromLeaderboard, affiliation
          }
        }
        pageInfo {
          endCursor,hasNextPage
        }
      }
    }
  |}
];

let updateTeams = (updateTeamsCB, endCursor, hasNextPage, teams, nodes) => {
  let updatedTeams =
    (
      switch (nodes) {
      | None => [||]
      | Some(teamsArray) => teamsArray |> Team.makeFromJS
      }
    )
    |> ArrayUtils.flatten
    |> Array.append(teams);

  let teams =
    switch (hasNextPage, endCursor) {
    | (_, None)
    | (false, Some(_)) => Page.FullyLoaded(updatedTeams)
    | (true, Some(cursor)) => Page.PartiallyLoaded(updatedTeams, cursor)
    };

  updateTeamsCB(teams);
};

let getTeams =
    (courseId, cursor, updateTeamsCB, selectedLevelId, search, teams, tags) => {
  (
    switch (selectedLevelId, search, cursor) {
    | (Some(levelId), Some(search), Some(cursor)) =>
      CourseTeamsQuery.make(
        ~courseId,
        ~levelId,
        ~search,
        ~after=cursor,
        ~tags,
        (),
      )
    | (Some(levelId), Some(search), None) =>
      CourseTeamsQuery.make(~courseId, ~levelId, ~search, ~tags, ())
    | (None, Some(search), Some(cursor)) =>
      CourseTeamsQuery.make(~courseId, ~search, ~after=cursor, ~tags, ())
    | (Some(levelId), None, Some(cursor)) =>
      CourseTeamsQuery.make(~courseId, ~levelId, ~after=cursor, ~tags, ())
    | (Some(levelId), None, None) =>
      CourseTeamsQuery.make(~courseId, ~levelId, ~tags, ())
    | (None, Some(search), None) =>
      CourseTeamsQuery.make(~courseId, ~search, ~tags, ())
    | (None, None, Some(cursor)) =>
      CourseTeamsQuery.make(~courseId, ~after=cursor, ~tags, ())
    | (None, None, None) => CourseTeamsQuery.make(~courseId, ~tags, ())
    }
  )
  |> GraphqlQuery.sendQuery(AuthenticityToken.fromHead())
  |> Js.Promise.then_(response => {
       response##courseTeams##nodes
       |> updateTeams(
            updateTeamsCB,
            response##courseTeams##pageInfo##endCursor,
            response##courseTeams##pageInfo##hasNextPage,
            teams,
          );
       Js.Promise.resolve();
     })
  |> ignore;
};

let teamsList = teams =>
  switch ((teams: Page.t)) {
  | Unloaded => [||]
  | PartiallyLoaded(teams, _cursor) => teams
  | FullyLoaded(teams) => teams
  };

[@react.component]
let make =
    (
      ~levels,
      ~courseId,
      ~tags,
      ~updateTeamsCB,
      ~selectedLevelId,
      ~search,
      ~pagedTeams,
      ~selectedStudents,
      ~selectStudentCB,
      ~deselectStudentCB,
      ~showEditFormCB,
    ) => {
  React.useEffect1(
    () => {
      getTeams(courseId, None, updateTeamsCB, None, None, [||], [||]);
      None;
    },
    [|courseId|],
  );

  let selectedStudentsList = selectedStudents |> List.map(((s, _)) => s);

  <div className="pb-6 px-6">
    <div className="max-w-3xl mx-auto w-full">
      <div className="w-full py-3 rounded-b-lg">
        {teamsList(pagedTeams)
         |> Array.map(team => {
              let isSingleStudent = team |> Team.isSingleStudent;
              <div
                key={team |> Team.id}
                id={team |> Team.name}
                className="student-team-container flex items-strecth shadow bg-white rounded-lg mb-4 overflow-hidden">
                <div className="flex flex-col flex-1 w-3/5">
                  {team
                   |> Team.students
                   |> Array.map(student => {
                        let isChecked =
                          selectedStudentsList |> List.mem(student);
                        let checkboxId =
                          "select-student-" ++ (student |> Student.id);
                        let teamId = team |> Team.id;
                        <div
                          key={student |> Student.id}
                          id={student |> Student.name}
                          className="student-team__card h-full cursor-pointer flex items-center bg-white">
                          <div className="flex flex-1 w-3/5 h-full">
                            <div className="flex items-center w-full">
                              <label
                                className="flex items-center h-full border-r text-gray-500 leading-tight font-bold px-4 py-5 hover:bg-gray-100"
                                htmlFor=checkboxId>
                                <input
                                  className="leading-tight"
                                  type_="checkbox"
                                  id=checkboxId
                                  checked=isChecked
                                  onChange={
                                    isChecked
                                      ? _e => {
                                          deselectStudentCB(student);
                                        }
                                      : (
                                        _e => {
                                          selectStudentCB(student, teamId);
                                        }
                                      )
                                  }
                                />
                              </label>
                              <a
                                className="flex flex-1 self-stretch items-center py-4 px-4 hover:bg-gray-100"
                                id={(student |> Student.name) ++ "_edit"}
                                onClick={_e =>
                                  showEditFormCB(student, teamId)
                                }>
                                {switch (student |> Student.avatarUrl) {
                                 | Some(avatarUrl) =>
                                   <img
                                     className="w-10 h-10 rounded-full mr-4 object-cover"
                                     src=avatarUrl
                                   />
                                 | None =>
                                   <Avatar
                                     name={student |> Student.name}
                                     className="w-10 h-10 mr-4"
                                   />
                                 }}
                                <div className="text-sm flex flex-col">
                                  <p
                                    className="text-black font-semibold inline-block ">
                                    {student |> Student.name |> str}
                                  </p>
                                  <div className="flex flex-wrap">
                                    {student
                                     |> Student.tags
                                     |> Array.map(tag =>
                                          <div
                                            key=tag
                                            className="bg-gray-200 border border-gray-500 rounded-lg mt-1 mr-1 py-px px-2 text-xs text-gray-900">
                                            {tag |> str}
                                          </div>
                                        )
                                     |> React.array}
                                  </div>
                                </div>
                              </a>
                            </div>
                          </div>
                        </div>;
                      })
                   |> React.array}
                </div>
                <div className="flex w-2/5 items-center">
                  <div className="w-3/5 py-4 px-3">
                    {isSingleStudent
                       ? ReasonReact.null
                       : <div className="students-team--name mb-5">
                           <p className="text-xs"> {"Team" |> str} </p>
                           <h4> {team |> Team.name |> str} </h4>
                         </div>}
                  </div>
                  <div className="w-2/5 text-center">
                    <span
                      className="inline-flex flex-col items-center rounded bg-gray-200 px-2 pt-2 pb-1 border">
                      <div className="text-xs font-semibold">
                        {"Level" |> str}
                      </div>
                      <div className="font-bold">
                        {team
                         |> Team.levelId
                         |> Level.unsafeLevelNumber(levels, "TeamsList")
                         |> str}
                      </div>
                    </span>
                  </div>
                </div>
              </div>;
            })
         |> React.array}
      </div>
      {switch ((pagedTeams: Page.t)) {
       | Unloaded
       | FullyLoaded(_) => React.null
       | PartiallyLoaded(teams, cursor) =>
         <div>
           <button
             className="btn btn-primary"
             onClick={_ =>
               getTeams(
                 courseId,
                 Some(cursor),
                 updateTeamsCB,
                 selectedLevelId,
                 search,
                 teams,
                 tags,
               )
             }>
             {"Load More" |> str}
           </button>
         </div>
       }}
    </div>
  </div>;
};
