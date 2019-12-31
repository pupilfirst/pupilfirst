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

type state = {
  searchInput: string,
  filter: Filter.t,
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

let handleClick = (suggestion, setState) =>
  setState(state =>
    {
      searchInput: "",
      filter:
        switch (suggestion.resourceType) {
        | Tag => state.filter |> Filter.addTag(suggestion.title)
        | Level(id) => state.filter |> Filter.changeLevelId(Some(id))
        },
    }
  );

let applyFilter = (filter, setState, updateFilterCB) => {
  updateFilterCB(filter);
  setState(state => {...state, searchInput: "", filter});
};

let clearFilter = (setState, updateFilterCB) =>
  applyFilter(Filter.empty(), setState, updateFilterCB);

let search = (searchInput, setState, tags, levels) => {
  // Remove all excess space characters from the user input.
  let normalizedString =
    searchInput
    |> Js.String.trim
    |> Js.String.replaceByRe(
         Js.Re.fromStringWithFlags("\\s+", ~flags="g"),
         " ",
       );
  switch (normalizedString) {
  | "" => [||]
  | searchString =>
    let searchResults =
      suggestions(tags, levels)
      |> Js.Array.filter(suggestion =>
           suggestion.title
           |> String.lowercase_ascii
           |> Js.String.includes(searchString |> String.lowercase_ascii)
         )
      |> ArrayUtils.copyAndSort((x, y) => String.compare(x.title, y.title))
      |> Array.map(suggestion =>
           <span
             title={"Pick tag " ++ suggestion.title}
             key={suggestion.title}
             className="inline-flex cursor-pointer items-center bg-gray-200 border border-gray-500 text-gray-900 hover:shadow hover:border-primary-500 hover:bg-primary-100 hover:text-primary-600 rounded-lg px-2 py-px mt-1 mr-1 text-xs overflow-hidden"
             onMouseDown={_e => handleClick(suggestion, setState)}>
             {suggestion.title |> str}
           </span>
         );

    searchResults;
  };
};

let handleRemoveFilter =
    (title, resourceType, state, setState, updateFilterCB) => {
  let filter =
    switch (resourceType) {
    | Some(r) =>
      switch (r) {
      | Level(_) => state.filter |> Filter.removeLevelId

      | Tag => state.filter |> Filter.removeTag(title)
      }
    | None => state.filter |> Filter.removeSearchString
    };
  updateFilterCB(filter);
  setState(state => {...state, filter});
};

let tagPill = (title, resourceType, state, setState, updateFilterCB) => {
  <span
    key=title
    className="inline-flex cursor-pointer items-center bg-gray-200 border border-gray-500 text-gray-900 rounded-lg px-2 py-px mt-1 mr-1 text-xs overflow-hidden ">
    {title |> str}
    <span
      className="ml-1 text-red-500 px-1 border-2 border-red-200 m-1 hover:shadow hover:border-red-500 hover:bg-red-100 hover:text-red-600"
      onClick={_ =>
        handleRemoveFilter(
          title,
          resourceType,
          state,
          setState,
          updateFilterCB,
        )
      }>
      {"x" |> str}
    </span>
  </span>;
};

let computeSelectedFilters = (filter, levels, state, setState, updateFilterCB) => {
  let level =
    switch (filter |> Filter.levelId) {
    | Some(id) => [|
        {
          let levelTitle =
            id |> Level.unsafeLevel(levels, "Search") |> Level.title;
          tagPill(
            levelTitle,
            Some(Level(id)),
            state,
            setState,
            updateFilterCB,
          );
        },
      |]
    | None => [||]
    };
  let searchString =
    switch (filter |> Filter.searchString) {
    | Some(s) =>
      s |> Js.String.trim == ""
        ? [||] : [|tagPill(s, None, state, setState, updateFilterCB)|]
    | None => [||]
    };

  let tags =
    filter
    |> Filter.tags
    |> Array.map(t => tagPill(t, Some(Tag), state, setState, updateFilterCB));

  searchString |> Array.append(tags) |> Array.append(level);
};

let handleOnchange = (setState, event) => {
  event |> ReactEvent.Form.persist;
  let searchInput = ReactEvent.Form.target(event)##value;
  setState(state =>
    {
      searchInput,
      filter: state.filter |> Filter.changeSearchString(Some(searchInput)),
    }
  );
};

[@react.component]
let make = (~filter, ~updateFilterCB, ~tags, ~levels) => {
  let (state, setState) = React.useState(() => {searchInput: "", filter});

  let selectedFilters =
    computeSelectedFilters(
      state.filter,
      levels,
      state,
      setState,
      updateFilterCB,
    );
  let results = search(state.searchInput, setState, tags, levels);
  <div className="mt-2">
    <div className="flex justify-between">
      <div> {selectedFilters |> React.array} </div>
      {selectedFilters |> ArrayUtils.isEmpty
         ? React.null
         : <button
             className="btn btn-danger ml-2 px-4"
             onClick={_ => clearFilter(setState, updateFilterCB)}>
             {"Clear" |> str}
           </button>}
    </div>
    <div className="flex ">
      <input
        autoComplete="off"
        value={state.searchInput}
        onChange={handleOnchange(setState)}
        className="appearance-none block bg-white leading-snug border border-gray-400 rounded-lg w-full py-3 px-4 mt-2 focus:outline-none focus:bg-white focus:border-gray-500"
        id="search"
        type_="text"
        placeholder="Search"
      />
      <button
        className="btn btn-default mt-2 ml-2"
        onClick={_ => applyFilter(state.filter, setState, updateFilterCB)}>
        {"Search" |> str}
      </button>
    </div>
    <div />
    {if (results |> ArrayUtils.isNotEmpty) {
       <div
         className="flex flex-wrap border border-gray-400 bg-white mt-1 rounded-lg shadow-lg searchable-tag-list__dropdown relative px-4 pt-2 pb-3">
         {results |> React.array}
       </div>;
     } else {
       React.null;
     }}
  </div>;
};
