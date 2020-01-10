[@bs.config {jsx: 3}];
open StudentsEditor__Types;

module Selectable = ReMultiselect__Selectable;

let updateFilter = (setSearchInput, updateFilterCB, filter) => {
  updateFilterCB(filter);
  setSearchInput(_ => "");
};

let makeSelectableLevel = level => {
  Selectable.make(
    ~id=Some(level |> Level.id),
    ~label=Some("Level " ++ (level |> Level.number |> string_of_int)),
    ~item=level |> Level.name,
    ~color="orange",
    ~searchString=level |> Level.title,
    ~resourceType="level",
    (),
  );
};

let makeSelectableTag = tag => {
  Selectable.make(
    ~id=None,
    ~label=Some("Tag"),
    ~item=tag,
    ~searchString="tag " ++ tag,
    ~resourceType="tag",
    (),
  );
};

let makeSelectableSearch = searchInput => {
  Selectable.make(
    ~id=None,
    ~label=Some("Name or Email"),
    ~item=searchInput,
    ~color="purple",
    ~searchString=searchInput,
    ~resourceType="nameOrEmail",
    (),
  );
};

let appliedFilters = (filter, levels) => {
  let level =
    switch (filter |> Filter.levelId) {
    | Some(id) => [|
        makeSelectableLevel(id |> Level.unsafeLevel(levels, "Search")),
      |]
    | None => [||]
    };
  let searchString =
    switch (filter |> Filter.searchString) {
    | Some(s) =>
      s |> Js.String.trim == "" ? [||] : [|makeSelectableSearch(s)|]
    | None => [||]
    };

  let tags = filter |> Filter.tags |> Array.map(t => makeSelectableTag(t));

  searchString |> Array.append(tags) |> Array.append(level);
};

let selections = (tags, levels, filter, searchInput) => {
  let tagSuggestions =
    tags
    |> Js.Array.filter(t => !(filter |> Filter.tags |> Array.mem(t)))
    |> Array.map(t => makeSelectableTag(t));
  let levelSuggestions =
    (
      switch (filter |> Filter.levelId) {
      | Some(levelId) =>
        levels |> Js.Array.filter(l => l |> Level.id != levelId)
      | None => levels
      }
    )
    |> Array.map(l => makeSelectableLevel(l));
  let searchSuggestion =
    searchInput |> Js.String.trim == ""
      ? [||] : [|makeSelectableSearch(searchInput)|];

  searchSuggestion
  |> Array.append(tagSuggestions)
  |> Array.append(levelSuggestions);
};

let updateSelection = (filter, updateFilterCB, setSearchInput, selectable) => {
  (
    switch (selectable |> Selectable.id) {
    | Some(id) => filter |> Filter.changeLevelId(Some(id))
    | None =>
      selectable |> Selectable.resourceType == "tag"
        ? filter |> Filter.addTag(selectable |> Selectable.item)
        : filter
          |> Filter.changeSearchString(Some(selectable |> Selectable.item))
    }
  )
  |> updateFilter(setSearchInput, updateFilterCB);
};

let clearSelection = (filter, updateFilterCB, selectable) => {
  let newFilter =
    switch (selectable |> Selectable.id) {
    | Some(_) => filter |> Filter.removeLevelId
    | None =>
      selectable |> Selectable.resourceType == "tag"
        ? filter |> Filter.removeTag(selectable |> Selectable.item)
        : filter |> Filter.removeSearchString
    };

  updateFilterCB(newFilter);
};
let updateSearchInput = (setSearchInput, searchInput) => {
  setSearchInput(_ => searchInput);
};

[@react.component]
let make = (~filter, ~updateFilterCB, ~tags, ~levels) => {
  let (searchInput, setSearchInput) = React.useState(() => "");
  <ReMultiselect
    unselected={selections(tags, levels, filter, searchInput)}
    selected={appliedFilters(filter, levels)}
    updateSelectionCB={updateSelection(
      filter,
      updateFilterCB,
      setSearchInput,
    )}
    clearSelectionCB={clearSelection(filter, updateFilterCB)}
    value=searchInput
    onChange={updateSearchInput(setSearchInput)}
  />;
};
