[@bs.config {jsx: 3}];

let notFoundIcon: string = [%raw "require('./images/no-students-found.svg')"];

let str = React.string;

open StudentsEditor__Types;

module CourseTeamsQuery = [%graphql
  {|
    query($courseId: ID!, $levelId: ID, $search: String, $after: String, $tags: [String!], $sortBy: String!) {
      courseTeams(courseId: $courseId, levelId: $levelId, search: $search, first: 20, after: $after, tags: $tags, sortBy: $sortBy) {
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
    (courseId, cursor, updateTeamsCB, teams, filter, setLoadingCB, loading) => {
  let tags = filter |> Filter.tags;
  let selectedLevelId = filter |> Filter.levelId;
  let search = filter |> Filter.searchString;
  let sortBy = filter |> Filter.sortByStrings;
  setLoadingCB(loading);
  (
    switch (selectedLevelId, search, cursor) {
    | (Some(levelId), Some(search), Some(cursor)) =>
      CourseTeamsQuery.make(
        ~courseId,
        ~levelId,
        ~search,
        ~after=cursor,
        ~tags,
        ~sortBy,
        (),
      )
    | (Some(levelId), Some(search), None) =>
      CourseTeamsQuery.make(~courseId, ~levelId, ~search, ~tags, ~sortBy, ())
    | (None, Some(search), Some(cursor)) =>
      CourseTeamsQuery.make(
        ~courseId,
        ~search,
        ~after=cursor,
        ~tags,
        ~sortBy,
        (),
      )
    | (Some(levelId), None, Some(cursor)) =>
      CourseTeamsQuery.make(
        ~courseId,
        ~levelId,
        ~after=cursor,
        ~tags,
        ~sortBy,
        (),
      )
    | (Some(levelId), None, None) =>
      CourseTeamsQuery.make(~courseId, ~levelId, ~tags, ~sortBy, ())
    | (None, Some(search), None) =>
      CourseTeamsQuery.make(~courseId, ~search, ~tags, ~sortBy, ())
    | (None, None, Some(cursor)) =>
      CourseTeamsQuery.make(~courseId, ~after=cursor, ~tags, ~sortBy, ())
    | (None, None, None) =>
      CourseTeamsQuery.make(~courseId, ~tags, ~sortBy, ())
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

let studentAvatar = student => {
  switch (student |> Student.avatarUrl) {
  | Some(avatarUrl) =>
    <img
      className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden flex-shrink-0 mt-1 md:mt-0 mr-2 md:mr-3 object-cover"
      src=avatarUrl
    />
  | None =>
    <Avatar
      name={student |> Student.name}
      className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden flex-shrink-0 mt-1 md:mt-0 mr-2 md:mr-3 object-cover"
    />
  };
};

let levelInfo = (levels, team) =>
  <span
    className="inline-flex flex-col items-center rounded bg-orange-100 border border-orange-300 px-2 pt-2 pb-1 border">
    <div className="text-xs font-semibold"> {"Level" |> str} </div>
    <div className="font-bold">
      {team
       |> Team.levelId
       |> Level.unsafeLevelNumber(levels, "TeamsList")
       |> str}
    </div>
  </span>;

let teamCard =
    (
      team,
      selectedStudentIds,
      selectStudentCB,
      deselectStudentCB,
      showEditFormCB,
      levels,
    ) => {
  let isSingleStudent = team |> Team.isSingleStudent;
  let teamId = team |> Team.id;
  <div
    key=teamId
    id={team |> Team.name}
    className="student-team-container flex items-strecth shadow bg-white rounded-lg mb-3 overflow-hidden">
    <div className="flex flex-col flex-1 w-3/5">
      {team
       |> Team.students
       |> Array.map(student => {
            let studentId = student |> Student.id;
            let isChecked = selectedStudentIds |> Array.mem(studentId);
            let checkboxId = "select-student-" ++ studentId;

            <div
              key=studentId
              id={student |> Student.name}
              className="student-team__card h-full cursor-pointer flex items-center bg-white">
              <div className="flex flex-1 w-3/5 h-full">
                <div className="flex items-center w-full">
                  <label
                    className="flex items-center h-full text-gray-500 leading-tight font-bold px-4 py-5 hover:bg-gray-100"
                    htmlFor=checkboxId>
                    <input
                      className="leading-tight"
                      type_="checkbox"
                      id=checkboxId
                      checked=isChecked
                      onChange={
                        isChecked
                          ? _e => {
                              deselectStudentCB(studentId);
                            }
                          : (
                            _e => {
                              selectStudentCB(student, team);
                            }
                          )
                      }
                    />
                  </label>
                  <a
                    className="flex flex-1 items-center py-4 px-4 hover:bg-gray-100 justify-between"
                    id={(student |> Student.name) ++ "_edit"}
                    onClick={_e => showEditFormCB(student, teamId)}>
                    <div className="flex">
                      {studentAvatar(student)}
                      <div className="text-sm flex flex-col">
                        <p className="text-black font-semibold inline-block ">
                          {student |> Student.name |> str}
                        </p>
                        <div className="flex flex-wrap">
                          {student
                           |> Student.tags
                           |> Array.map(tag =>
                                <div
                                  key=tag
                                  className="bg-gray-300 rounded mt-1 mr-1 py-px px-2 text-xs text-gray-900">
                                  {tag |> str}
                                </div>
                              )
                           |> React.array}
                        </div>
                      </div>
                    </div>
                    {isSingleStudent ? team |> levelInfo(levels) : React.null}
                  </a>
                </div>
              </div>
            </div>;
          })
       |> React.array}
    </div>
    {isSingleStudent
       ? React.null
       : <div className="flex w-2/5 items-center border-l border-gray-200">
           <div className="w-4/6 py-4 pl-5 pr-4">
             <div className="students-team--name mb-5">
               <p
                 className="inline-block text-xs bg-green-200 leading-tight px-1 py-px rounded">
                 {"Team" |> str}
               </p>
               <h4> {team |> Team.name |> str} </h4>
             </div>
           </div>
           <div className="w-2/6 text-right pr-4">
             {team |> levelInfo(levels)}
           </div>
         </div>}
  </div>;
};

let showEmpty = (filter, updateFilterCB) =>
  <div className="flex flex-col-reverse items-center p-5 text-center">
    {filter |> Filter.isEmpty
       ? <div> {"No students here." |> str} </div>
       : <div className="max-w-md w-full">
           <img className="w-full" src=notFoundIcon />
           <p className="text-2xl font-semibold text-gray-800 mt-2">
             {"Sorry, No students found :(" |> str}
           </p>
           <button
             className="btn btn-large btn-default mt-4"
             onClick={_ => updateFilterCB(filter |> Filter.clear)}>
             {"Clear Filter" |> str}
           </button>
         </div>}
  </div>;

let showTeams =
    (
      selectedStudentIds,
      selectStudentCB,
      deselectStudentCB,
      showEditFormCB,
      levels,
      filter,
      updateFilterCB,
      teams,
    ) => {
  switch (teams) {
  | [||] => showEmpty(filter, updateFilterCB)
  | teams =>
    teams
    |> Array.map(team => {
         teamCard(
           team,
           selectedStudentIds,
           selectStudentCB,
           deselectStudentCB,
           showEditFormCB,
           levels,
         )
       })
    |> React.array
  };
};

[@react.component]
let make =
    (
      ~levels,
      ~courseId,
      ~updateTeamsCB,
      ~filter,
      ~pagedTeams,
      ~selectedStudentIds,
      ~selectStudentCB,
      ~deselectStudentCB,
      ~showEditFormCB,
      ~loading,
      ~setLoadingCB,
      ~updateFilterCB,
      ~refreshTeams,
    ) => {
  React.useEffect1(
    () => {
      getTeams(
        courseId,
        None,
        updateTeamsCB,
        [||],
        filter,
        setLoadingCB,
        Loading.Reloading,
      );

      None;
    },
    [|refreshTeams|],
  );

  <div className="pb-6">
    <div className="max-w-3xl mx-auto w-full">
      <div>
        {switch ((pagedTeams: Page.t)) {
         | Unloaded =>
           SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
         | PartiallyLoaded(_, _)
         | FullyLoaded(_) =>
           pagedTeams
           |> Page.teams
           |> showTeams(
                selectedStudentIds,
                selectStudentCB,
                deselectStudentCB,
                showEditFormCB,
                levels,
                filter,
                updateFilterCB,
              )
         }}
      </div>
      {switch ((pagedTeams: Page.t)) {
       | Unloaded
       | FullyLoaded(_) => React.null
       | PartiallyLoaded(teams, cursor) =>
         loading == Loading.LoadingMore
           ? SkeletonLoading.multiple(
               ~count=3,
               ~element=SkeletonLoading.card(),
             )
           : <div className="pt-4">
               <button
                 className="btn btn-primary-ghost cursor-pointer w-full"
                 onClick={_ =>
                   getTeams(
                     courseId,
                     Some(cursor),
                     updateTeamsCB,
                     teams,
                     filter,
                     setLoadingCB,
                     Loading.LoadingMore,
                   )
                 }>
                 {"Load More" |> str}
               </button>
             </div>
       }}
    </div>
  </div>;
};
