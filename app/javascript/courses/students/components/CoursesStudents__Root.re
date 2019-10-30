[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__Root.css")|}];

open CoursesStudents__Types;
let str = React.string;

type filter = {
  search: option(string),
  level: option(Level.t),
};

type state = {
  loading: bool,
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
      | Some(teamsArray) => teamsArray |> TeamInfo.decodeJS
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
      loading: false,
    }
  );
};

let getTeams =
    (
      authenticityToken,
      courseId,
      cursor,
      setState,
      selectedLevel,
      search,
      teams,
    ) => {
  setState(state => {...state, loading: true});
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

let onClickForLevelSelector = (level, setState, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setState(state =>
    {
      ...state,
      filter: {
        level,
        search: state.filter.search,
      },
      teams: Unloaded,
    }
  );
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
          teams: Unloaded,
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
      teams: Unloaded,
    }
  );
};

let dropDownButtonText = level =>
  "Level "
  ++ (level |> Level.number |> string_of_int)
  ++ " | "
  ++ (level |> Level.name);

let dropdownShowAllButton = (selectedLevel, setState) =>
  switch (selectedLevel) {
  | Some(_) => [|
      <button
        className="p-3 w-full text-left font-semibold focus:outline-none"
        onClick={onClickForLevelSelector(None, setState)}>
        {"All Levels" |> str}
      </button>,
    |]
  | None => [||]
  };

let showDropdown = (levels, selectedLevel, setState) => {
  let contents =
    dropdownShowAllButton(selectedLevel, setState)
    ->Array.append(
        levels
        |> Level.sort
        |> Array.map(level =>
             <button
               className="p-3 w-full text-left font-semibold focus:outline-none"
               onClick={onClickForLevelSelector(Some(level), setState)}>
               {dropDownButtonText(level) |> str}
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

let openOverlayCB = () => {
  Js.log("Open Overlay");
};

[@react.component]
let make = (~levels, ~course) => {
  let (state, setState) =
    React.useState(() =>
      {
        loading: false,
        teams: Unloaded,
        searchInputString: None,
        filter: {
          search: None,
          level: None,
        },
      }
    );
  let courseId = course |> Course.id;
  React.useEffect2(
    () => {
      switch ((state.teams: Teams.t)) {
      | Unloaded =>
        getTeams(
          AuthenticityToken.fromHead(),
          courseId,
          None,
          setState,
          state.filter.level,
          state.filter.search,
          [||],
        )
      | FullyLoaded(_)
      | PartiallyLoaded(_, _) => ()
      };
      None;
    },
    (state.filter.level, state.filter.search),
  );
  <div>
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
                   type_="button"
                   className="course-students__student-search-input-cancel-button absolute right-0 top-0 text-gray-700 cursor-pointer hover:text-gray-900 text-lg px-1 py-px z-10 mr-2 flex items-center h-full focus:outline-none">
                   <i className="fas fa-times-circle" />
                 </button>
               | None => React.null
               }}
            </div>
            <button className="btn btn-default"> {"Search" |> str} </button>
          </form>
          <div className="flex-shrink-0 pt-4 md:pt-0 w-full md:w-auto">
            {showDropdown(levels, state.filter.level, setState)}
          </div>
        </div>
      </div>
      <div className="max-w-3xl mx-auto">
        {switch (state.teams) {
         | Unloaded =>
           SkeletonLoading.multiple(
             ~count=10,
             ~element=SkeletonLoading.userCard(),
           )
         | PartiallyLoaded(teams, cursor) =>
           [|
             <CoursesStudents__TeamsList levels teams openOverlayCB />,
             {state.loading
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
                        setState,
                        state.filter.level,
                        state.filter.search,
                        teams,
                      )
                    }>
                    {"Load More..." |> str}
                  </button>},
           |]
           |> React.array
         | FullyLoaded(teams) =>
           <CoursesStudents__TeamsList levels teams openOverlayCB />
         }}
      </div>
    </div>
  </div>;
};
