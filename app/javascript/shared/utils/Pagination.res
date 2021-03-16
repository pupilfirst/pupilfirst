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

  let update = (t, fn) =>
    switch t {
    | Unloaded => Unloaded
    | PartiallyLoaded(entries, cursor) => PartiallyLoaded(fn(entries), cursor)
    | FullyLoaded(entries) => FullyLoaded(fn(entries))
    }

  let make = (items, hasNextPage, endCursor) => {
    switch (hasNextPage, endCursor) {
    | (_, None)
    | (false, Some(_)) =>
      FullyLoaded(items)
    | (true, Some(cursor)) => PartiallyLoaded(items, cursor)
    }
  }
}
