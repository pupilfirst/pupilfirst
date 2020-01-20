[@bs.config {jsx: 3}];
open StudentsEditor__Types;

let str = React.string;

module Identifier = {
  type t =
    | Level(string)
    | Tag
    | NameOrEmail;
};

module MultiselectDropdown = MultiselectDropdown.Make(Identifier);

let updateFilter = (setSearchInput, updateFilterCB, filter) => {
  updateFilterCB(filter);
  setSearchInput(_ => "");
};

let makeSelectableLevel = level => {
  MultiselectDropdown.Selectable.make(
    ~label="Level " ++ (level |> Level.number |> string_of_int),
    ~value=level |> Level.name,
    ~color="orange",
    ~searchString=level |> Level.title,
    ~identifier=Level(level |> Level.id),
    (),
  );
};

let makeSelectableTag = tag => {
  MultiselectDropdown.Selectable.make(
    ~label="Tag",
    ~value=tag,
    ~searchString="tag " ++ tag,
    ~identifier=Tag,
    (),
  );
};

let makeSelectableSearch = searchInput => {
  MultiselectDropdown.Selectable.make(
    ~label="Name or Email",
    ~value=searchInput,
    ~color="purple",
    ~searchString=searchInput,
    ~identifier=NameOrEmail,
    (),
  );
};

let selected = (filter, levels) => {
  let level =
    switch (filter |> Filter.levelId) {
    | Some(id) => [|
        makeSelectableLevel(id |> Level.unsafeFind(levels, "Search")),
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

let unselected = (tags, levels, filter, searchInput) => {
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

let select = (filter, updateFilterCB, setSearchInput, selectable) => {
  (
    switch (selectable |> MultiselectDropdown.Selectable.identifier) {
    | Level(id) => filter |> Filter.changeLevelId(Some(id))
    | Tag =>
      filter
      |> Filter.addTag(selectable |> MultiselectDropdown.Selectable.value)
    | NameOrEmail =>
      filter
      |> Filter.changeSearchString(
           Some(selectable |> MultiselectDropdown.Selectable.value),
         )
    }
  )
  |> updateFilter(setSearchInput, updateFilterCB);
};

let deselect = (filter, updateFilterCB, selectable) => {
  let newFilter =
    switch (selectable |> MultiselectDropdown.Selectable.identifier) {
    | Level(_id) => filter |> Filter.removeLevelId
    | Tag =>
      filter
      |> Filter.removeTag(selectable |> MultiselectDropdown.Selectable.value)
    | NameOrEmail => filter |> Filter.removeSearchString
    };

  updateFilterCB(newFilter);
};
let updateSearchInput = (setSearchInput, searchInput) => {
  setSearchInput(_ => searchInput);
};

[@react.component]
let make = (~filter, ~updateFilterCB, ~tags, ~levels) => {
  let (searchInput, setSearchInput) = React.useState(() => "");
  let id = "search";
  <div className="inline-block w-full">
    <label className="block text-tiny font-semibold" htmlFor=id>
      {"Filter by:" |> str}
    </label>
    <MultiselectDropdown
      unselected={unselected(tags, levels, filter, searchInput)}
      selected={selected(filter, levels)}
      selectCB={select(filter, updateFilterCB, setSearchInput)}
      deselectCB={deselect(filter, updateFilterCB)}
      value=searchInput
      onChange={updateSearchInput(setSearchInput)}
      id
      placeholder="Type name, tag or level"
    />
  </div>;
};
