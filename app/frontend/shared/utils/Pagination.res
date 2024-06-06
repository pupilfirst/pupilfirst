@module("./assets/not-found.svg")
external notFoundSVG: string = "default"

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

  let length = t =>
    switch t {
    | Unloaded => 0
    | PartiallyLoaded(entries, _) => Js.Array2.length(entries)
    | FullyLoaded(entries) => Js.Array2.length(entries)
    }

  let getCursor = t =>
    switch t {
    | Unloaded => None
    | PartiallyLoaded(_, cursor) => Some(cursor)
    | FullyLoaded(_) => None
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

  let showStats = (totalCount, loadedCount, singularName, pluralName) =>
    <div className="pt-8 pb-4 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
      {(
        totalCount == loadedCount
          ? t(
              ~variables=[("singular_name", singularName), ("plural_name", pluralName)],
              ~count=totalCount,
              "fully_loaded_text",
            )
          : t(
              ~variables=[
                ("total", string_of_int(totalCount)),
                ("loaded", string_of_int(loadedCount)),
                ("plural_name", pluralName),
              ],
              "partially_loaded_text",
            )
      )->React.string}
    </div>

  let renderEntries = (
    entries,
    emptyMessage,
    totalEntriesCount,
    entriesView,
    singularResourceName,
    pluralResourceName,
  ) => {
    <div className="w-full">
      {ArrayUtils.isEmpty(entries)
        ? <div
            className="flex flex-col mx-auto bg-white rounded-md border p-6 justify-center items-center">
            <img className="w-30 h-30" src={notFoundSVG} alt={t("not_found_alt")} />
            <h4 className="mt-3 text-base md:text-lg text-center font-semibold">
              {emptyMessage->React.string}
            </h4>
          </div>
        : entriesView(entries)}
      {showStats(
        totalEntriesCount,
        Array.length(entries),
        singularResourceName,
        pluralResourceName,
      )}
    </div>
  }

  let renderView = (
    ~pagedItems,
    ~loading,
    ~emptyMessage,
    ~entriesView,
    ~totalEntriesCount,
    ~loadMore,
    ~singularResourceName,
    ~pluralResourceName,
  ) => {
    <div>
      {switch pagedItems {
      | Unloaded =>
        <div> {SkeletonLoading.multiple(~count=4, ~element=SkeletonLoading.card())} </div>
      | PartiallyLoaded(entries, cursor) =>
        <div>
          {renderEntries(
            entries,
            emptyMessage,
            totalEntriesCount,
            entriesView,
            singularResourceName,
            pluralResourceName,
          )}
          {switch loading {
          | LoadingV2.LoadingMore =>
            <div> {SkeletonLoading.multiple(~count=1, ~element=SkeletonLoading.card())} </div>
          | Reloading(times) => ReactUtils.nullUnless(loadMore(cursor), ArrayUtils.isEmpty(times))
          }}
        </div>
      | FullyLoaded(entries) =>
        renderEntries(
          entries,
          emptyMessage,
          totalEntriesCount,
          entriesView,
          singularResourceName,
          pluralResourceName,
        )
      }}
      {showLoading(pagedItems, loading)}
    </div>
  }
}
