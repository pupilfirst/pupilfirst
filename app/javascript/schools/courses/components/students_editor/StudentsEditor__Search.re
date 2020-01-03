[@bs.config {jsx: 3}];

open StudentsEditor__Types;

let str = ReasonReact.string;

type resourceType =
  | Level(id)
  | Tag
and id = string;

type suggestion = {
  title: string,
  resourceType,
};

let suggestions = (tags, levels) => {
  let tagSuggestions =
    tags |> Array.map(t => {title: "Tag: " ++ t, resourceType: Tag});
  let levelSuggestions =
    levels
    |> Array.map(l =>
         {title: l |> Level.title, resourceType: Level(l |> Level.id)}
       );
  tagSuggestions |> Array.append(levelSuggestions);
};

let updateFilter = (setSearchInput, updateFilterCB, filter) => {
  updateFilterCB(filter);
  setSearchInput(_ => "");
};

let applyFilter =
    (filter, setSearchInput, updateFilterCB, title, resourceType) => {
  (
    switch (resourceType) {
    | Some(rt) =>
      switch (rt) {
      | Tag => filter |> Filter.addTag(title)
      | Level(id) => filter |> Filter.changeLevelId(Some(id))
      }
    | None => filter |> Filter.changeSearchString(Some(title))
    }
  )
  |> updateFilter(setSearchInput, updateFilterCB);
};

let clearFilter = (setSearchInput, updateFilterCB) => {
  Filter.empty() |> updateFilter(setSearchInput, updateFilterCB);
};

let searchByName = (searchInput, applyFilterCB) => {
  [|
    <div key="searchByName" className="mt-2">
      <span> {"Search for " |> str} </span>
      <button
        onClick={_ => applyFilterCB(searchInput, None)}
        title={"Pick filter " ++ searchInput}
        className="inline-flex cursor-pointer items-center bg-gray-200 border border-gray-500 text-gray-900 hover:shadow hover:border-primary-500 hover:bg-primary-100 hover:text-primary-600 rounded-lg px-2 py-px mt-1 mr-1 text-xs overflow-hidden">
        {searchInput |> str}
      </button>
    </div>,
  |];
};

let showSuggestions = (applyFilterCB, title, suggestions: array(suggestion)) => {
  switch (suggestions) {
  | [||] => [||]
  | suggestions => [|
      <div key=title className="mt-2">
        <div> {" Matching " ++ title |> str} </div>
        {suggestions
         |> Array.map(suggestion =>
              <button
                title={"Pick filter " ++ suggestion.title}
                key={suggestion.title}
                className="inline-flex cursor-pointer items-center bg-gray-200 border border-gray-500 text-gray-900 hover:shadow hover:border-primary-500 hover:bg-primary-100 hover:text-primary-600 rounded-lg px-2 py-px mt-1 mr-1 text-xs overflow-hidden"
                onMouseDown={_e =>
                  applyFilterCB(
                    suggestion.title,
                    Some(suggestion.resourceType),
                  )
                }>
                {suggestion.title |> str}
              </button>
            )
         |> React.array}
      </div>,
    |]
  };
};

let searchResult = (searchInput, applyFilterCB, tags, levels) => {
  // Remove all excess space characters from the user input.
  let normalizedString = {
    searchInput
    |> Js.String.trim
    |> Js.String.replaceByRe(
         Js.Re.fromStringWithFlags("\\s+", ~flags="g"),
         " ",
       );
  };

  switch (normalizedString) {
  | "" => [||]
  | searchString =>
    let suggestions =
      suggestions(tags, levels)
      |> Js.Array.filter(suggestion =>
           suggestion.title
           |> String.lowercase_ascii
           |> Js.String.includes(searchString |> String.lowercase_ascii)
         )
      |> ArrayUtils.copyAndSort((x, y) => String.compare(x.title, y.title));

    let levelSuggestions =
      suggestions |> Js.Array.filter(f => f.resourceType != Tag);
    let tagSuggestions =
      suggestions |> Js.Array.filter(f => f.resourceType == Tag);

    showSuggestions(applyFilterCB, "Tags", tagSuggestions)
    |> Array.append(
         showSuggestions(applyFilterCB, "Levels", levelSuggestions),
       )
    |> Array.append(searchByName(searchInput, applyFilterCB));
  };
};

let handleRemoveFilter = (filter, updateFilterCB, title, resourceType) => {
  let newFilter =
    switch (resourceType) {
    | Some(r) =>
      switch (r) {
      | Level(_) => filter |> Filter.removeLevelId

      | Tag => filter |> Filter.removeTag(title)
      }
    | None => filter |> Filter.removeSearchString
    };
  updateFilterCB(newFilter);
};

let tagPill = (title, resourceType, removeFilterCB) => {
  <span
    key=title
    className="inline-flex cursor-pointer items-center bg-gray-200 border border-gray-500 text-gray-900 rounded-lg px-2 py-px mt-1 mr-1 text-xs overflow-hidden ">
    {title |> str}
    <span
      className="ml-1 text-red-500 px-1 border-2 border-red-200 m-1 hover:shadow hover:border-red-500 hover:bg-red-100 hover:text-red-600"
      onClick={_ => removeFilterCB(title, resourceType)}>
      {"x" |> str}
    </span>
  </span>;
};

let computeSelectedFilters = (filter, levels, removeFilterCB) => {
  let level =
    switch (filter |> Filter.levelId) {
    | Some(id) => [|
        {
          let levelTitle =
            id |> Level.unsafeLevel(levels, "Search") |> Level.title;
          tagPill(levelTitle, Some(Level(id)), removeFilterCB);
        },
      |]
    | None => [||]
    };
  let searchString =
    switch (filter |> Filter.searchString) {
    | Some(s) =>
      s |> Js.String.trim == "" ? [||] : [|tagPill(s, None, removeFilterCB)|]
    | None => [||]
    };

  let tags =
    filter
    |> Filter.tags
    |> Array.map(t => tagPill(t, Some(Tag), removeFilterCB));

  searchString |> Array.append(tags) |> Array.append(level);
};

let handleOnchange = (setSearchInput, event) => {
  let searchInput = ReactEvent.Form.target(event)##value;
  setSearchInput(_ => searchInput);
};

[@react.component]
let make = (~filter, ~updateFilterCB, ~tags, ~levels) => {
  let (searchInput, setSearchInput) = React.useState(() => "");

  let selectedFilters =
    computeSelectedFilters(
      filter,
      levels,
      handleRemoveFilter(filter, updateFilterCB),
    );

  <div className="mt-2">
    <div className="flex justify-between">
      <div> {selectedFilters |> React.array} </div>
      {selectedFilters |> ArrayUtils.isEmpty
         ? React.null
         : <button
             className="btn btn-danger ml-2 px-4"
             onClick={_ => clearFilter(setSearchInput, updateFilterCB)}>
             {"Clear" |> str}
           </button>}
    </div>
    <div className="flex ">
      <input
        autoComplete="off"
        value=searchInput
        onChange={handleOnchange(setSearchInput)}
        className="appearance-none block bg-white leading-snug border border-gray-400 rounded-lg w-full py-3 px-4 mt-2 focus:outline-none focus:bg-white focus:border-gray-500"
        id="search"
        type_="text"
        placeholder="Search"
      />
    </div>
    <div />
    {if (searchInput != "") {
       <div
         className="border border-gray-400 bg-white mt-1 rounded-lg shadow-lg relative px-4 pt-2 pb-3">
         {searchResult(
            searchInput,
            applyFilter(filter, setSearchInput, updateFilterCB),
            tags,
            levels,
          )
          |> React.array}
       </div>;
     } else {
       React.null;
     }}
  </div>;
};
