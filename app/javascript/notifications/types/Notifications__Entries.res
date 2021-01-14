type t =
  | Unloaded
  | PartiallyLoaded(array<Notifications__Entry.t>, string)
  | FullyLoaded(array<Notifications__Entry.t>)

let toArray = t =>
  switch t {
  | Unloaded => []
  | PartiallyLoaded(entries, _) => entries
  | FullyLoaded(entries) => entries
  }
