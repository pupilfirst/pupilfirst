[@bs.config {jsx: 3}];

open StudentsEditor__Types;

let str = ReasonReact.string;

type resourceType =
  | Level(id)
  | Tag
  | NameOrEmail
and id = string;

type suggestion = {
  title: string,
  name: string,
  searchString: string,
  resourceType,
};

let suggestions = (tags, levels, filter) => {
  let tagSuggestions =
    tags
    |> Array.map(t =>
         {title: "Tag", name: t, searchString: t, resourceType: Tag}
       );
  let levelSuggestions =
    (
      switch (filter |> Filter.levelId) {
      | Some(levelId) =>
        levels |> Js.Array.filter(l => l |> Level.id != levelId)
      | None => levels
      }
    )
    |> Array.map(l =>
         {
           title: "Level " ++ (l |> Level.number |> string_of_int),
           name: l |> Level.name,
           searchString: l |> Level.title,
           resourceType: Level(l |> Level.id),
         }
       );
  tagSuggestions |> Array.append(levelSuggestions);
};

let updateFilter = (setSearchInput, updateFilterCB, filter) => {
  updateFilterCB(filter);
  setSearchInput(_ => "");
};

let applyFilter = (filter, setSearchInput, updateFilterCB, suggestion) => {
  (
    switch (suggestion.resourceType) {
    | Tag => filter |> Filter.addTag(suggestion.name)
    | Level(id) => filter |> Filter.changeLevelId(Some(id))
    | NameOrEmail =>
      filter |> Filter.changeSearchString(Some(suggestion.name))
    }
  )
  |> updateFilter(setSearchInput, updateFilterCB);
};

let clearFilter = (setSearchInput, updateFilterCB) => {
  Filter.empty() |> updateFilter(setSearchInput, updateFilterCB);
};

let suggestionTitle = suggestion => {
  let name = suggestion.name;
  switch (suggestion.resourceType) {
  | Tag => "Pick tag " ++ name
  | Level(_) => "Pick " ++ name
  | NameOrEmail => "Search " ++ name
  };
};

let tagPillClasses = (resourceType, showHover) => {
  "cursor-pointer items-center rounded mt-2 text-xs overflow-hidden "
  ++ (
    switch (resourceType) {
    | Level(_) =>
      "bg-orange-200 text-orange-800 "
      ++ (showHover ? "hover:bg-orange-300 hover:text-orange-900" : "")
    | Tag =>
      "bg-gray-200 text-gray-800 "
      ++ (showHover ? "hover:bg-gray-300 hover:text-gray-900" : "")
    | NameOrEmail =>
      "bg-purple-200 text-purple-800 "
      ++ (showHover ? "hover:bg-purple-300 hover:text-purple-900" : "")
    }
  );
};

let searchResult = (searchInput, applyFilterCB, tags, levels, filter) => {
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
      suggestions(tags, levels, filter)
      |> Js.Array.filter(suggestion =>
           suggestion.searchString
           |> String.lowercase_ascii
           |> Js.String.includes(searchString |> String.lowercase_ascii)
         )
      |> ArrayUtils.copyAndSort((x, y) => String.compare(x.name, y.name))
      |> Array.append([|
           {
             title: "Name or Email",
             name: searchString,
             searchString,
             resourceType: NameOrEmail,
           },
         |]);

    suggestions
    |> Array.map(suggestion =>
         <button
           title={suggestionTitle(suggestion)}
           key={suggestion.name}
           className="px-2 py-px block text-xs"
           onClick={_e => applyFilterCB(suggestion)}>
           <span className="mr-2"> {suggestion.title |> str} </span>
           <span className={tagPillClasses(suggestion.resourceType, true)}>
             {suggestion.name |> str}
           </span>
         </button>
       );
  };
};

let handleRemoveFilter = (filter, updateFilterCB, name, resourceType) => {
  let newFilter =
    switch (resourceType) {
    | Level(_) => filter |> Filter.removeLevelId
    | Tag => filter |> Filter.removeTag(name)
    | NameOrEmail => filter |> Filter.removeSearchString
    };

  updateFilterCB(newFilter);
};

let tagPill = (name, resourceType, removeFilterCB) => {
  <div key=name className={tagPillClasses(resourceType, false)}>
    <span className="pl-2 py-px">
      {(
         switch (resourceType) {
         | NameOrEmail
         | Level(_) => name
         | Tag => "Tag: " ++ name
         }
       )
       |> str}
    </span>
    <button
      title={"Remove filter " ++ name}
      className="ml-2 text-red-500 px-2 py-px border-l"
      onClick={_ => removeFilterCB(name, resourceType)}>
      <FaIcon classes="fas fa-times" />
    </button>
  </div>;
};

let appliedFilters = (filter, levels, removeFilterCB) => {
  let level =
    switch (filter |> Filter.levelId) {
    | Some(id) => [|
        {
          let levelTitle =
            id |> Level.unsafeLevel(levels, "Search") |> Level.title;
          tagPill(levelTitle, Level(id), removeFilterCB);
        },
      |]
    | None => [||]
    };
  let searchString =
    switch (filter |> Filter.searchString) {
    | Some(s) =>
      s |> Js.String.trim == ""
        ? [||] : [|tagPill(s, NameOrEmail, removeFilterCB)|]
    | None => [||]
    };

  let tags =
    filter |> Filter.tags |> Array.map(t => tagPill(t, Tag, removeFilterCB));

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
    appliedFilters(
      filter,
      levels,
      handleRemoveFilter(filter, updateFilterCB),
    );

  <div className="w-full relative">
    <div className="flex flex-col">
      <label className="block text-tiny uppercase font-semibold">
        {"Filter by:" |> str}
      </label>
      <div className="flex justify-between items-end">
        <div> {selectedFilters |> React.array} </div>
        {selectedFilters |> ArrayUtils.isEmpty
           ? React.null
           : <button
               className="btn btn-subtle btn-small ml-2 px-4 border"
               onClick={_ => clearFilter(setSearchInput, updateFilterCB)}>
               {"Clear Filter" |> str}
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
            filter,
          )
          |> React.array}
       </div>;
     } else {
       React.null;
     }}
  </div>;
};
