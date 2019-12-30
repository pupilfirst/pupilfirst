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
  setState(state => {...state, searchInput: ""});
};

let clearFilter = (filter, setState, updateFilterCB) =>
  if (filter == Filter.empty()) {
    setState(state => {...state, searchInput: ""});
  } else {
    applyFilter(Filter.empty(), setState, updateFilterCB);
  };

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

let computeSelectedFilters = (filter, levels) => {
  let levelTitle =
    switch (filter |> Filter.levelId) {
    | Some(l) => [|l |> Level.unsafeLevel(levels, "Search") |> Level.title|]
    | None => [||]
    };
  let searchString =
    switch (filter |> Filter.searchString) {
    | Some(s) => s |> Js.String.trim == "" ? [||] : [|s|]
    | None => [||]
    };

  searchString
  |> Array.append(filter |> Filter.tags)
  |> Array.append(levelTitle)
  |> Array.map(f =>
       <span
         key=f
         className="inline-flex cursor-pointer items-center bg-gray-200 border border-gray-500 text-gray-900 hover:shadow hover:border-primary-500 hover:bg-primary-100 hover:text-primary-600 rounded-lg px-2 py-px mt-1 mr-1 text-xs overflow-hidden">
         {f |> str}
       </span>
     );
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

  let selectedFilters = computeSelectedFilters(state.filter, levels);
  let results = search(state.searchInput, setState, tags, levels);
  <div className="mt-2">
    <div className="flex justify-between">
      <div> {selectedFilters |> React.array} </div>
      {selectedFilters |> ArrayUtils.isEmpty
         ? React.null
         : <button
             className="btn btn-danger ml-2 px-4"
             onClick={_ => clearFilter(filter, setState, updateFilterCB)}>
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
} /* }*/;

// type state = string;
// let handleClick = (tag, send, clickCB) => {
//   clickCB(tag);
//   send("");
// };
// let search =
//     (state, send, allowNewTags, selectedTags, unselectedTags, addTagCB) => {
//   // Remove all excess space characters from the user input.
//   let normalizedString =
//     state
//     |> Js.String.trim
//     |> Js.String.replaceByRe(
//          Js.Re.fromStringWithFlags("\\s+", ~flags="g"),
//          " ",
//        );
//   switch (normalizedString) {
//   | "" => []
//   | searchString =>
//     let allTags =
//       List.append(selectedTags, unselectedTags)
//       |> List.map(String.lowercase_ascii);
//     /* If addition of tag is allowed, and it IS new, then display that option at the front. */
//     let initial =
//       if (allowNewTags
//           && !(allTags |> List.mem(searchString |> String.lowercase_ascii))) {
//         [
//           <span
//             title={"Add new tag " ++ searchString}
//             key=searchString
//             onMouseDown={_e => handleClick(searchString, send, addTagCB)}
//             className="inline-flex cursor-pointer items-center bg-primary-100 border border-dashed border-primary-500 text-primary-700 hover:shadow-md hover:text-primary-800 rounded-lg px-2 py-px mt-1 mr-2 text-xs overflow-hidden">
//             {searchString |> str}
//             <i className="fas fa-plus ml-1 text-sm text-primary-600" />
//           </span>,
//         ];
//       } else {
//         [];
//       };
//     let searchResults =
//       unselectedTags
//       |> List.filter(tag =>
//            tag
//            |> String.lowercase_ascii
//            |> Js.String.includes(searchString |> String.lowercase_ascii)
//          )
//       |> List.sort(String.compare)
//       |> List.map(tag =>
//            <span
//              title={"Pick tag " ++ tag}
//              key=tag
//              className="inline-flex cursor-pointer items-center bg-gray-200 border border-gray-500 text-gray-900 hover:shadow hover:border-primary-500 hover:bg-primary-100 hover:text-primary-600 rounded-lg px-2 py-px mt-1 mr-1 text-xs overflow-hidden"
//              onMouseDown={_e => handleClick(tag, send, addTagCB)}>
//              {tag |> str}
//            </span>
//          );
//     initial @ searchResults;
//   };
// };
// let reducer = (_state, searchString) => {
//   searchString;
// };
// [@react.component]
// let make = (~filter, ~selectedTags, ~addTagCB, ~removeTagCB, ~allowNewTags) => {
//   let (state, send) = React.useReducer(reducer, "");
//   let results =
//     search(state, send, allowNewTags, selectedTags, unselectedTags, addTagCB);
//   <div className="mt-2">
//     {if (selectedTags |> ListUtils.isNotEmpty) {
//        <div className="flex flex-wrap">
//          {selectedTags
//           |> List.sort(String.compare)
//           |> List.map(tag =>
//                <div
//                  key=tag
//                  className="flex items-center bg-gray-200 border border-gray-500 rounded-lg mt-1 mr-1 text-xs text-gray-900 overflow-hidden">
//                  <span className="px-2 py-px"> {tag |> str} </span>
//                  <span
//                    title={"Remove tag " ++ tag}
//                    className="flex items-center px-2 h-full cursor-pointer px-2 text-gray-700 hover:text-black hover:bg-gray-300 border-l border-gray-400"
//                    onClick={_e => handleClick(tag, send, removeTagCB)}>
//                    <i className="fas fa-times" />
//                  </span>
//                </div>
//              )
//           |> Array.of_list
//           |> ReasonReact.array}
//        </div>;
//      } else {
//        ReasonReact.null;
//      }}
//     <input
//       value=state
//       onChange={event => send(ReactEvent.Form.target(event)##value)}
//       className="appearance-none block bg-white leading-snug border border-gray-400 rounded-lg w-full py-3 px-4 mt-2 focus:outline-none focus:bg-white focus:border-gray-500"
//       id="tags"
//       type_="text"
//       placeholder={
//         allowNewTags ? "Search for, or add new tags" : "Select tags"
//       }
//     />
//     {if (results |> ListUtils.isNotEmpty) {
//        <div
//          className="flex flex-wrap border border-gray-400 bg-white mt-1 rounded-lg shadow-lg searchable-tag-list__dropdown relative px-4 pt-2 pb-3">
//          {results |> Array.of_list |> ReasonReact.array}
//        </div>;
//      } else {
//        ReasonReact.null;
//      }}
//   </div>;
