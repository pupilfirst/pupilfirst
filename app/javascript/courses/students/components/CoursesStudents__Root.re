[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__Root.css")|}];

open CoursesStudents__Types;
let str = React.string;

type filter = {
  search: option(string),
  level: option(Level.t),
};

type loading =
  | NotLoading
  | Reloading
  | LoadingMore;

type state = {
  loading,
  teams: Teams.t,
  searchInputString: option(string),
  filter,
};

module TeamsQuery = [%graphql
  {|
    query($courseId: ID!, $levelId: ID, $search: String, $after: String) {
      teams(courseId: $courseId, levelId: $levelId, search: $search, first: 10, after: $after) {
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

let updateTeams = (setState, endCursor, hasNextPage, teams, nodes) => {
  let updatedTeams =
    (
      switch (nodes) {
      | None => [||]
      | Some(teamsArray) => teamsArray |> TeamInfo.makeFromJS
      }
    )
    |> Array.to_list
    |> List.flatten
    |> Array.of_list
    |> Array.append(teams);
  setState(state =>
    {
      ...state,
      teams:
        switch (hasNextPage, endCursor) {
        | (_, None)
        | (false, Some(_)) => FullyLoaded(updatedTeams)
        | (true, Some(cursor)) => PartiallyLoaded(updatedTeams, cursor)
        },
      loading: NotLoading,
    }
  );
};

let getTeams =
    (courseId, cursor, setState, selectedLevel, search, teams, loading) => {
  setState(state => {...state, loading});
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
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##teams##nodes
       |> updateTeams(
            setState,
            response##teams##pageInfo##endCursor,
            response##teams##pageInfo##hasNextPage,
            teams,
          );
       Js.Promise.resolve();
     })
  |> ignore;
};

let dropdownElementClasses = (level, selectedLevel) => {
  "p-3 w-full flex justify-between md:items-center text-left font-semibold focus:outline-none "
  ++ (
    switch (selectedLevel, level) {
    | (Some(sl), Some(l)) when l |> Level.id == (sl |> Level.id) => "bg-gray-200 text-primary-500"
    | (None, None) => "bg-gray-200 text-primary-500"
    | _ => ""
    }
  );
};

let updateLevel = (level, setState) => {
  setState(state =>
    {
      ...state,
      filter: {
        level,
        search: state.filter.search,
      },
    }
  );
};

let onClickForLevelSelector = (level, selectedLevel, setState, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  switch (selectedLevel, level) {
  | (Some(sl), Some(l)) when l |> Level.id == (sl |> Level.id) => ()
  | _ => updateLevel(level, setState)
  };
};

let onSubmitSearch = (setState, event) => {
  ReactEvent.Form.preventDefault(event);
  let search = ReactEvent.Form.target(event)##student_search##value;
  let isValidString = search |> Js.String.trim |> Js.String.length > 0;
  isValidString
    ? setState(state =>
        {
          ...state,
          filter: {
            search,
            level: state.filter.level,
          },
        }
      )
    : ();
};

let onClearSearch = (setState, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setState(state =>
    {
      ...state,
      searchInputString: None,
      filter: {
        search: None,
        level: state.filter.level,
      },
    }
  );
};

let dropDownButtonText = level =>
  "Level "
  ++ (level |> Level.number |> string_of_int)
  ++ " | "
  ++ (level |> Level.name);

let showDropdown = (levels, selectedLevel, setState) => {
  let contents =
    [|
      <button
        className={dropdownElementClasses(None, selectedLevel)}
        onClick={onClickForLevelSelector(None, selectedLevel, setState)}>
        {"All Levels" |> str}
      </button>,
    |]
    ->Array.append(
        levels
        |> Level.sort
        |> Array.map(level =>
             <button
               className={dropdownElementClasses(Some(level), selectedLevel)}
               onClick={onClickForLevelSelector(
                 Some(level),
                 selectedLevel,
                 setState,
               )}>
               <span className="pr-2">
                 {dropDownButtonText(level) |> str}
               </span>
               <span
                 className="flex-shrink-0 bg-secondary-500 rounded px-1 pb-px text-white leading-tight">
                 <Icon className="if i-users-regular text-xs" />
                 <span className="text-xs ml-1">
                   {level |> Level.teamsInLevel |> string_of_int |> str}
                 </span>
               </span>
             </button>
           ),
      );

  let selected =
    <button
      className="bg-white px-4 py-2 border font-semibold rounded-lg focus:outline-none w-full md:w-auto flex justify-between">
      {(
         switch (selectedLevel) {
         | None => "All Levels"
         | Some(level) => dropDownButtonText(level)
         }
       )
       |> str}
      <span className="pl-2 ml-2 border-l">
        <i className="fas fa-chevron-down text-sm" />
      </span>
    </button>;

  <Dropdown selected contents right=true />;
};

let updateSearchInputString = (setState, event) => {
  let searchInputString = ReactEvent.Form.target(event)##value;
  setState(state => {...state, searchInputString});
};

let openOverlayCB = (studentId, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  ReasonReactRouter.push("/students/" ++ studentId ++ "/report");
};

let disableSearchButton = state => {
  switch (state.searchInputString) {
  | None => true
  | Some(string) =>
    !(string |> String.trim |> String.length > 0)
    || (
      switch (state.filter.search) {
      | None => false
      | Some(searchString) => string == searchString
      }
    )
  };
};

let applicableLevels = levels => {
  levels |> Js.Array.filter(level => Level.number(level) != 0);
};

[@react.component]
let make = (~levels, ~course, ~userId) => {
  let (state, setState) =
    React.useState(() =>
      {
        loading: NotLoading,
        teams: Unloaded,
        searchInputString: None,
        filter: {
          search: None,
          level: None,
        },
      }
    );
  let courseId = course |> Course.id;

  let url = ReasonReactRouter.useUrl();

  React.useEffect1(
    () => {
      getTeams(
        courseId,
        None,
        setState,
        state.filter.level,
        state.filter.search,
        [||],
        Reloading,
      );

      None;
    },
    [|state.filter|],
  );

  <div>
    {switch (url.path) {
     | ["students", studentId, "report"] =>
       <CoursesStudents__StudentOverlay courseId studentId levels userId />
     | _ => React.null
     }}
    <div className="bg-gray-100 pt-12 pb-8 px-3 -mt-7">
      <div className="w-full bg-gray-100 relative md:sticky md:top-0">
        <div
          className="max-w-3xl mx-auto flex flex-col md:flex-row items-end lg:items-center justify-between pt-4 pb-4">
          <form
            className="flex items-center justify-between w-full md:w-auto"
            onSubmit={event => onSubmitSearch(setState, event)}>
            <div className="relative w-full md:w-auto mr-2">
              <input
                name="student_search"
                value={
                  switch (state.searchInputString) {
                  | None => ""
                  | Some(string) => string
                  }
                }
                onChange={event => updateSearchInputString(setState, event)}
                className="course-students__student-search-input appearance-none bg-white border rounded block text-sm appearance-none leading-normal px-3 py-2 pr-8 focus:outline-none focus:border-primary-400"
                placeholder="Search by student or team name..."
              />
              {switch (state.filter.search) {
               | Some(_text) =>
                 <button
                   onClick={event => onClearSearch(setState, event)}
                   name="clear-student-search"
                   type_="button"
                   className="course-students__student-search-input-cancel-button absolute right-0 top-0 text-gray-700 cursor-pointer hover:text-gray-900 text-lg px-1 py-px z-10 mr-2 flex items-center h-full focus:outline-none">
                   <i className="fas fa-times-circle" />
                 </button>
               | None => React.null
               }}
            </div>
            <button
              disabled={disableSearchButton(state)}
              className="btn btn-default">
              {"Search" |> str}
            </button>
          </form>
          <div className="flex-shrink-0 pt-4 md:pt-0 w-full md:w-auto">
            {showDropdown(
               applicableLevels(levels),
               state.filter.level,
               setState,
             )}
          </div>
        </div>
      </div>
      <div className=" max-w-3xl mx-auto">
        {switch (state.teams) {
         | Unloaded =>
           SkeletonLoading.multiple(
             ~count=10,
             ~element=SkeletonLoading.userCard(),
           )
         | PartiallyLoaded(teams, cursor) =>
           <div>
             <CoursesStudents__TeamsList levels teams openOverlayCB />
             {switch (state.loading) {
              | LoadingMore =>
                SkeletonLoading.multiple(
                  ~count=3,
                  ~element=SkeletonLoading.card(),
                )
              | NotLoading =>
                <button
                  className="btn btn-primary-ghost cursor-pointer w-full mt-8"
                  onClick={_ =>
                    getTeams(
                      courseId,
                      Some(cursor),
                      setState,
                      state.filter.level,
                      state.filter.search,
                      teams,
                      LoadingMore,
                    )
                  }>
                  {"Load More..." |> str}
                </button>
              | Reloading => React.null
              }}
           </div>
         | FullyLoaded(teams) =>
           <CoursesStudents__TeamsList levels teams openOverlayCB />
         }}
      </div>
    </div>
    {switch (state.teams) {
     | Unloaded => React.null

     | _ =>
       let loading =
         switch (state.loading) {
         | NotLoading => false
         | Reloading => true
         | LoadingMore => false
         };
       <LoadingSpinner loading />;
     }}
  </div>;
};
