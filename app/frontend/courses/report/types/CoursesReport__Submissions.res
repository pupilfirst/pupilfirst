type targetStatus = [#PendingReview | #Rejected | #Completed]

type sortDirection = [#Ascending | #Descending]

type filter = {status: option<targetStatus>}

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

let makeFilter = status => {status: status}

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

let filterEq = (status, filter) => filter.status == status

let needsReloading = (selectedStatus, sortDirection, t) =>
  switch t {
  | Unloaded => true
  | FullyLoaded(data)
  | PartiallyLoaded(data, _) =>
    !(data.filter |> filterEq(selectedStatus) && data.sortDirection == sortDirection)
  }
