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
  let tagSuggestions = tags |> Array.map(t => {title: t, resourceType: Tag});
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

let suggestionTitle = (title, resourceType) => {
  switch (resourceType) {
  | Some(rt) =>
    switch (rt) {
    | Tag => "Pick tag " ++ title
    | Level(_) => "Pick " ++ title
    }
  | None => "Search " ++ title
  };
};

let tagPillClasses = (resourceType, showHover) => {
  "inline-flex cursor-pointer items-center rounded mt-1 mr-1 text-xs overflow-hidden "
  ++ (
    switch (resourceType) {
    | Some(r) =>
      switch (r) {
      | Level(_) =>
        "bg-orange-200 text-orange-800 "
        ++ (showHover ? "hover:bg-orange-300 hover:text-orange-900" : "")
      | Tag =>
        "bg-gray-200 text-gray-800 "
        ++ (showHover ? "hover:bg-gray-300 hover:text-gray-900" : "")
      }
    | None =>
      "bg-purple-200 text-purple-800 "
      ++ (showHover ? "hover:bg-purple-300 hover:text-purple-900" : "")
    }
  );
};

let searchByName = (searchInput, applyFilterCB) => {
  [|
    <div key="searchByName" className="mt-2">
      <span> {"Search for " |> str} </span>
      <button
        onClick={_ => applyFilterCB(searchInput, None)}
        title={suggestionTitle(searchInput, None)}
        className={tagPillClasses(None, true)}>
        <span className="px-2 py-px"> {searchInput |> str} </span>
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
                title={suggestionTitle(
                  suggestion.title,
                  Some(suggestion.resourceType),
                )}
                key={suggestion.title}
                className={tagPillClasses(
                  Some(suggestion.resourceType),
                  true,
                )}
                onClick={_e =>
                  applyFilterCB(
                    suggestion.title,
                    Some(suggestion.resourceType),
                  )
                }>
                <span className="px-2 py-px"> {suggestion.title |> str} </span>
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
  <div key=title className={tagPillClasses(resourceType, false)}>
    <span className="pl-2 py-px">
      {(
         switch (resourceType) {
         | Some(r) =>
           switch (r) {
           | Level(_) => title
           | Tag => "Tag: " ++ title
           }
         | None => title
         }
       )
       |> str}
    </span>
    <button
      title={"Remove filter " ++ title}
      className="ml-2 text-red-500 px-2 py-px border-l"
      onClick={_ => removeFilterCB(title, resourceType)}>
      <FaIcon classes="fas fa-times" />
    </button>
  </div>;
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

  <div className="w-full relative">
    <div className="flex flex-col">
      <label className="block text-tiny uppercase font-semibold">
        {"Filter by:" |> str}
      </label>
      <div className="flex items-center">
        <div> {selectedFilters |> React.array} </div>
        {selectedFilters |> ArrayUtils.isEmpty
           ? React.null
           : <button
               className="btn btn-danger btn-small ml-2 px-4"
               onClick={_ => clearFilter(setSearchInput, updateFilterCB)}>
               {"Clear" |> str}
             </button>}
      </div>
      <input
        autoComplete="off"
        value=searchInput
        onChange={handleOnchange(setSearchInput)}
        className="appearance-none block bg-white border border-gray-400 rounded w-full py-2 px-4 mt-1 focus:outline-none focus:bg-white focus:border-primary-300"
        id="search"
        type_="text"
        placeholder="Search for name, tag or level"
      />
    </div>
    <div />
    {if (searchInput |> String.trim != "") {
       <div
         className="w-full absolute border border-gray-400 bg-white mt-1 rounded-lg shadow-lg px-4 pt-2 pb-3">
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
