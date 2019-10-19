[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__Root.css")|}];

open CoursesStudents__Types;
let str = React.string;

type state = {
  teams: Teams.t,
  studentSearchString: option(string),
  selectedLevel: option(Level.t),
};

let onClickForLevelSelector = (level, setState, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setState(state => {...state, selectedLevel: level, teams: Unloaded});
};

let onChangeSearchString = (setState, event) => {
  let studentSearchString = ReactEvent.Form.target(event)##value;
  setState(state => {...state, studentSearchString});
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
      className="bg-white px-4 py-2 border border-gray-400 font-semibold rounded-lg focus:outline-none w-full md:w-auto flex justify-between">
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

[@react.component]
let make = (~levels, ~course) => {
  let (state, setState) =
    React.useState(() =>
      {teams: Unloaded, studentSearchString: None, selectedLevel: None}
    );
  <div>
    <div className="bg-gray-100 pt-12 pb-8 px-3 -mt-7">
      <div className="w-full bg-gray-100 relative md:sticky md:top-0">
        <div
          className="max-w-3xl mx-auto flex flex-col md:flex-row items-end lg:items-center justify-between pt-4 pb-4">
          <div className="flex items-center justify-between pl-3">
            <input
              type_="search"
              className="bg-white border rounded-lg block w-64 text-sm appearance-none leading-normal mr-2 px-3 py-2"
              placeholder="Search by student name..."
              value={
                switch (state.studentSearchString) {
                | Some(string) => string
                | None => ""
                }
              }
              onChange={event => onChangeSearchString(setState, event)}
            />
          </div>
          <div className="flex-shrink-0 pt-4 md:pt-0 w-full md:w-auto">
            {showDropdown(levels, state.selectedLevel, setState)}
          </div>
        </div>
      </div>
      <div className="max-w-3xl mx-auto">
        <CoursesStudents__TeamsList
          levels
          selectedLevel={state.selectedLevel}
          teams={state.teams}
          courseId={course |> Course.id}
          updateTeamsCB={updateTeams(~setState)}
        />
      </div>
    </div>
  </div>;
};
