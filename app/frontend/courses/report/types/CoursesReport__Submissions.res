type targetStatus = [#PendingReview | #Rejected | #Completed]

type sortDirection = [#Ascending | #Descending]

type filter = {
  level: option<CoursesReport__Level.t>,
  status: option<targetStatus>,
}

type data = {
  submissions: array<CoursesReport__Submission.t>,
  filter: filter,
  sortDirection: sortDirection,
}

let make = (~submissions, ~filter, ~sortDirection) => {
  submissions: submissions,
  filter: filter,
  sortDirection: sortDirection,
}

let makeFilter = (level, status) => {level: level, status: status}

type rec t =
  | Unloaded
  | PartiallyLoaded(data, cursor)
  | FullyLoaded(data)
and cursor = string

let partiallyLoaded = (~submissions, ~filter, ~sortDirection, ~cursor) => PartiallyLoaded(
  {submissions: submissions, filter: filter, sortDirection: sortDirection},
  cursor,
)

let fullyLoaded = (~submissions, ~filter, ~sortDirection) => FullyLoaded({
  submissions: submissions,
  filter: filter,
  sortDirection: sortDirection,
})

let filterLevelId = level => level->Belt.Option.mapWithDefault("none", CoursesReport__Level.id)

let filterEq = (level, status, filter) =>
  filter.level |> filterLevelId == filterLevelId(level) && filter.status == status

let needsReloading = (selectedLevel, selectedStatus, sortDirection, t) =>
  switch t {
  | Unloaded => true
  | FullyLoaded(data)
  | PartiallyLoaded(data, _) =>
    !(data.filter |> filterEq(selectedLevel, selectedStatus) && data.sortDirection == sortDirection)
  }
