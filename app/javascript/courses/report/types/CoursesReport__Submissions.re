type targetStatus = [ | `Submitted | `Failed | `Passed];

type sortDirection = [ | `Ascending | `Descending];

type filter = {
  level: option(CoursesReport__Level.t),
  status: option(targetStatus),
};

type data = {
  submissions: array(CoursesReport__Submission.t),
  filter,
  sortDirection,
};

let make = (~submissions, ~filter, ~sortDirection) => {
  submissions,
  filter,
  sortDirection,
};

let makeFilter = (level, status) => {level, status};

type t =
  | Unloaded
  | PartiallyLoaded(data, cursor)
  | FullyLoaded(data)
and cursor = string;

let partiallyLoaded = (~submissions, ~filter, ~sortDirection, ~cursor) =>
  PartiallyLoaded({submissions, filter, sortDirection}, cursor);

let fullyLoaded = (~submissions, ~filter, ~sortDirection) =>
  FullyLoaded({submissions, filter, sortDirection});

let filterLevelId = level =>
  level->Belt.Option.mapWithDefault("none", CoursesReport__Level.id);

let filterEq = (level, status, filter) =>
  filter.level
  |> filterLevelId == filterLevelId(level)
  && filter.status == status;

let needsReloading = (selectedLevel, selectedStatus, sortDirection, t) =>
  switch (t) {
  | Unloaded => true
  | FullyLoaded(data)
  | PartiallyLoaded(data, _) =>
    !(
      data.filter
      |> filterEq(selectedLevel, selectedStatus)
      && data.sortDirection == sortDirection
    )
  };
