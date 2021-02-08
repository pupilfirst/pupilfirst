module type Item = {
  type t
}

module Make = (Item: Item) => {
  type t =
    | Unloaded
    | PartiallyLoaded(array<Item.t>, string)
    | FullyLoaded(array<Item.t>)

  let toArray = t =>
    switch t {
    | Unloaded => []
    | PartiallyLoaded(entries, _) => entries
    | FullyLoaded(entries) => entries
    }
}
