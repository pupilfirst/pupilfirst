[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__Root.css")|}];

open CoursesStudents__Types;
let str = React.string;

type state = {
  teams: Teams.t,
  search: option(string),
  selectedLevel: option(Level.t),
};

let onClickForLevelSelector = (level, setState, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setState(state => {...state, selectedLevel: level, teams: Unloaded});
};

let onSubmitSearchString = (setState, event) => {
  ReactEvent.Form.preventDefault(event);
  let search = ReactEvent.Form.target(event)##student_search##value;
  setState(state => {...state, search, teams: Unloaded});
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

let updateTeams = (~setState, ~teams, ~hasNextPage, ~endCursor) =>
  setState(state =>
    {
      ...state,
      teams:
        switch (hasNextPage, endCursor) {
        | (_, None)
        | (false, Some(_)) => FullyLoaded(teams)
        | (true, Some(cursor)) => PartiallyLoaded(teams, cursor)
        },
    }
  );

let openOverlayCB = () => {
  Js.log("Open Overlay");
};

[@react.component]
let make = (~levels, ~course) => {
  let (state, setState) =
    React.useState(() =>
      {teams: Unloaded, search: None, selectedLevel: None}
    );
  <div>
    <div className="bg-gray-100 pt-12 pb-8 px-3 -mt-7">
      <div className="w-full bg-gray-100 relative md:sticky md:top-0">
        <div
          className="max-w-3xl mx-auto flex flex-col md:flex-row items-end lg:items-center justify-between pt-4 pb-4">
          <form
            className="flex items-center justify-between w-full md:w-auto"
            onSubmit={event => onSubmitSearchString(setState, event)}>
            <div className="relative w-full md:w-auto mr-2">
              <input
                name="student_search"
                type_="search"
                className="course-students__student-search-input appearance-none bg-white border rounded block text-sm appearance-none leading-normal px-3 py-2 pr-8 focus:outline-none focus:border-primary-400"
                placeholder="Search by student or team name..."
              />
              <span
                className="course-students__student-search-input-cancel-button absolute right-0 top-0 text-gray-700 cursor-pointer hover:text-gray-900 text-lg px-1 py-px z-10 mr-2 flex items-center h-full focus:outline-none">
                <i className="fas fa-times-circle" />
              </span>
            </div>
            <button className="btn btn-default"> {"Search" |> str} </button>
          </form>
          <div className="flex-shrink-0 pt-4 md:pt-0 w-full md:w-auto">
            {showDropdown(levels, state.selectedLevel, setState)}
          </div>
        </div>
      </div>
      <div className="max-w-3xl mx-auto">
        <CoursesStudents__TeamsList
          levels
          selectedLevel={state.selectedLevel}
          search={state.search}
          teams={state.teams}
          course
          updateTeamsCB={updateTeams(~setState)}
          openOverlayCB
        />
      </div>
    </div>
  </div>;
};
