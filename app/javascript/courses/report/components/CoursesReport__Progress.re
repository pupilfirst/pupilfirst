open CoursesReport__Types;
let str = React.string;

type targetStatus = [ | `Submitted | `Failed | `Passed];

type sortDirection = [ | `Ascending | `Descending];

type sortBy = {
  criterion: string,
  criterionType: [ | `String | `Number],
};

type state = {
  selectedLevel: option(Level.t),
  selectedStatus: option(targetStatus),
  sortBy,
  sortDirection,
  filterString: string,
};

type action =
  | SelectLevel(Level.t)
  | DeselectLevel
  | SelectStatus(targetStatus)
  | DeselectStatus
  | UpdateSortDirection(sortDirection)
  | UpdateFilterString(string);

let statusString = targetStatus => {
  switch (targetStatus) {
  | `Submitted => "Submitted"
  | `Failed => "Failed"
  | `Passed => "Passed"
  };
};

module Selectable = {
  type t =
    | Level(Level.t)
    | TargetStatus(targetStatus);

  let label = t =>
    switch (t) {
    | Level(level) =>
      Some("Level " ++ (level |> Level.number |> string_of_int))
    | TargetStatus(_targetStatus) => Some("Status")
    };

  let value = t =>
    switch (t) {
    | Level(level) => level |> Level.name
    | TargetStatus(targetStatus) => statusString(targetStatus)
    };

  let searchString = t =>
    switch (t) {
    | Level(level) =>
      "level "
      ++ (level |> Level.number |> string_of_int)
      ++ " "
      ++ (level |> Level.name)
    | TargetStatus(targetStatus) => "status " ++ statusString(targetStatus)
    };

  let color = t =>
    switch (t) {
    | Level(_level) => "gray"
    | TargetStatus(status) =>
      switch (status) {
      | `Submitted => "blue"
      | `Passed => "green"
      | `Failed => "red"
      }
    };
  let level = level => Level(level);
  let targetStatus = targetStatus => TargetStatus(targetStatus);
};

module Multiselect = MultiselectDropdown.Make(Selectable);

let unselected = (levels, state) => {
  let unselectedLevels =
    levels
    |> Js.Array.filter(level =>
         state.selectedLevel
         |> OptionUtils.mapWithDefault(
              selectedLevel =>
                level |> Level.id != (selectedLevel |> Level.id),
              true,
            )
       )
    |> Array.map(Selectable.level);

  let unselectedStatus =
    [|`Submitted, `Failed, `Passed|]
    |> Js.Array.filter(status =>
         state.selectedStatus
         |> OptionUtils.mapWithDefault(
              selectedStatus => status == selectedStatus,
              true,
            )
       )
    |> Array.map(Selectable.targetStatus);

  unselectedLevels |> Array.append(unselectedStatus);
};

let selected = state => {
  let selectedLevel =
    state.selectedLevel
    |> OptionUtils.mapWithDefault(
         selectedLevel => [|Selectable.level(selectedLevel)|],
         [||],
       );

  let selectedStatus =
    state.selectedStatus
    |> OptionUtils.mapWithDefault(
         selectedStatus => {[|Selectable.targetStatus(selectedStatus)|]},
         [||],
       );

  selectedLevel |> Array.append(selectedStatus);
};

let onSelectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.TargetStatus(status) => send(SelectStatus(status))
  | Level(level) => send(SelectLevel(level))
  };

let onDeselectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.TargetStatus(_status) => send(DeselectStatus)
  | Level(_level) => send(DeselectStatus)
  };

module Sortable = {
  type t = sortBy;

  let criterion = t => t.criterion;
  let criterionType = t => t.criterionType;
};

module SubmissionsSorter = Sorter.Make(Sortable);

let submissionsSorter = (state, send) => {
  let criteria = [|{criterion: "Submitted At", criterionType: `Number}|];
  <div
    ariaLabel="Change submissions sorting"
    className="flex-shrink-0 mt-3 md:mt-0 md:ml-2">
    <label className="block text-tiny font-semibold uppercase">
      {"Sort by:" |> str}
    </label>
    <SubmissionsSorter
      criteria
      selectedCriterion={state.sortBy}
      direction={state.sortDirection}
      onDirectionChange={sortDirection => {
        send(UpdateSortDirection(sortDirection))
      }}
      onCriterionChange={_ => ()}
    />
  </div>;
};

let filterPlaceholder = state => {
  switch (state.selectedLevel, state.selectedStatus) {
  | (None, Some(_)) => "Filter by level"
  | (None, None) => "Filter by level, or by review status"
  | (Some(_), Some(_)) => "Filter by another level"
  | (Some(_), None) => "Filter by another level, or by review status"
  };
};

let reducer = (state, action) => {
  switch (action) {
  | SelectLevel(level) => {...state, selectedLevel: Some(level)}
  | DeselectLevel => {...state, selectedLevel: None}
  | SelectStatus(targetStatus) => {
      ...state,
      selectedStatus: Some(targetStatus),
    }
  | DeselectStatus => {...state, selectedStatus: None}
  | UpdateSortDirection(sortDirection) => {...state, sortDirection}
  | UpdateFilterString(filterString) => {...state, filterString}
  };
};

[@react.component]
let make = (~levels, ~submissions) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        selectedLevel: None,
        selectedStatus: Some(`Passed),
        sortDirection: `Ascending,
        filterString: "",
        sortBy: {
          criterion: "Submitted At",
          criterionType: `Number,
        },
      },
    );
  <div className="max-w-3xl mx-auto">
    {<div className="md:flex w-full items-start pb-4">
       <div className="flex-1">
         <label className="block text-tiny font-semibold uppercase">
           {"Filter by:" |> str}
         </label>
         <Multiselect
           id="filter"
           unselected={unselected(levels, state)}
           selected={selected(state)}
           onSelect={onSelectFilter(send)}
           onDeselect={onDeselectFilter(send)}
           value={state.filterString}
           onChange={filterString => send(UpdateFilterString(filterString))}
           placeholder={filterPlaceholder(state)}
         />
       </div>
       {submissionsSorter(state, send)}
     </div>}
  </div>;
};
