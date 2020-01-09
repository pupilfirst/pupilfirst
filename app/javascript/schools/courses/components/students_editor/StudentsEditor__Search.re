[@bs.config {jsx: 3}];
[%bs.raw {|require("./StudentsEditor__Search.css")|}];

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
    |> Js.Array.filter(t => !(filter |> Filter.tags |> Array.mem(t)))
    |> Array.map(t =>
         {
           title: "Tag:",
           name: t,
           searchString: "tag " ++ t,
           resourceType: Tag,
         }
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
           title: "Level " ++ (l |> Level.number |> string_of_int) ++ ":",
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
  "rounded text-xs overflow-hidden "
  ++ (
    switch (resourceType) {
    | Level(_) =>
      "bg-orange-200 text-orange-800 "
      ++ (showHover ? "hover:bg-orange-300 hover:text-orange-900" : "")
    | Tag =>
      "bg-gray-300 text-gray-900 "
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
             title: "Name or Email:",
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
           className="flex text-xs py-1 items-center w-full hover:bg-gray-200 focus:outline-none focus:bg-gray-200"
           onClick={_e => applyFilterCB(suggestion)}>
           <span className="mr-2 w-1/6 text-right">
             {suggestion.title |> str}
           </span>
           <span
             className={
               "px-2 py-px "
               ++ {
                 tagPillClasses(suggestion.resourceType, true);
               }
             }>
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
  <div
    key=name
    className={
      "inline-flex mt-1 mr-1 "
      ++ {
        tagPillClasses(resourceType, false);
      }
    }>
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
      className="ml-1 text-red-700 px-2 py-px flex focus:outline-none hover:bg-red-400 hover:text-white"
      onClick={_ => removeFilterCB(name, resourceType)}>
      <Icon className="if i-times-light" />
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
    <div>
      <label className="block text-tiny uppercase font-semibold">
        {"Filter by:" |> str}
      </label>
      <div
        className="flex flex-wrap items-center text-sm bg-white border border-gray-400 rounded w-full pt-1 pb-2 px-3 mt-1 focus:outline-none focus:bg-white focus:border-primary-300">
        {selectedFilters |> React.array}
        <input
          autoComplete="off"
          value=searchInput
          onChange={handleOnchange(setSearchInput)}
          className="flex-grow mt-1 appearance-none bg-transparent border-none text-gray-700 mr-3 py-1 leading-snug focus:outline-none"
          id="search"
          type_="text"
          placeholder="Type name, tag or level"
        />
      </div>
    </div>
    <div />
    {if (searchInput |> String.trim != "") {
       <div
         className="student-editor__search-dropdown w-full absolute border border-gray-400 bg-white mt-1 rounded-lg shadow-lg px-4 py-2">
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
