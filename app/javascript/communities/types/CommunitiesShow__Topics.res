type t =
  | Unloaded
  | PartiallyLoaded(array<CommunitiesShow__Topic.t>, string)
  | FullyLoaded(array<CommunitiesShow__Topic.t>)

let toArray = t =>
  switch t {
  | Unloaded => []
  | PartiallyLoaded(topics, _) => topics
  | FullyLoaded(topics) => topics
  }
