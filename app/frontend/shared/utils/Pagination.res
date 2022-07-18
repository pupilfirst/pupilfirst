let t = I18n.t(~scope="components.Pagination")

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

  let showLoading = (t, loading) => {
    switch t {
    | Unloaded => React.null
    | _ =>
      let isLoading = switch loading {
      | LoadingV2.Reloading(times) => ArrayUtils.isNotEmpty(times)
      | LoadingMore => false
      }

      <LoadingSpinner loading=isLoading />
    }
  }

  let showStats = (totalCount, loadedCount, name) =>
    <div className="pt-8 pb-4 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
      {(
        totalCount == loadedCount
          ? t(
              ~variables=[("total", string_of_int(totalCount)), ("name", name)],
              "fully_loaded_text",
            )
          : t(
              ~variables=[
                ("total", string_of_int(totalCount)),
                ("loaded", string_of_int(loadedCount)),
                ("name", name),
              ],
              "partially_loaded_text",
            )
      )->React.string}
    </div>
}
