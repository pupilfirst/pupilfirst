let str = ReasonReact.string;

type state = string;

let handleClick = (tag, send, clickCB) => {
  clickCB(tag);
  send("");
};

let component =
  ReasonReact.reducerComponent("SA_StudentsPanel_SearchableTagList");

let search =
    (state, send, allowNewTags, selectedTags, unselectedTags, addTagCB) =>
  switch (state) {
  | "" => []
  | searchString =>
    let allTags =
      List.append(selectedTags, unselectedTags) |> List.map(String.lowercase);
    /* If addition of tag is allowed, and it IS new, then display that option at the front. */
    let initial =
      if (allowNewTags
          && !(allTags |> List.mem(searchString |> String.lowercase))) {
        [
          <span
            title={"Add new tag " ++ searchString}
            key=searchString
            onMouseDown=(_e => handleClick(searchString, send, addTagCB))
            className="inline-flex cursor-pointer items-center bg-primary-100 border border-dashed border-primary-500 text-primary-700 hover:shadow-md hover:text-primary-800 rounded-lg px-2 py-px mt-1 mr-2 text-xs overflow-hidden">
            {searchString |> str}
            <i className="fas fa-plus ml-1 text-sm text-primary-600" />
          </span>,
        ];
      } else {
        [];
      };
    let searchResults =
      unselectedTags
      |> List.filter(tag =>
           tag
           |> String.lowercase
           |> Js.String.includes(searchString |> String.lowercase)
         )
      |> List.sort(String.compare)
      |> List.map(tag =>
           <span
             title={"Pick tag " ++ tag}
             key=tag
             className="inline-flex cursor-pointer items-center bg-gray-200 border border-gray-500 text-gray-900 hover:shadow hover:border-primary-500 hover:bg-primary-100 hover:text-primary-600 rounded-lg px-2 py-px mt-1 mr-1 text-xs overflow-hidden"
             onMouseDown=(_e => handleClick(tag, send, addTagCB))>
             {tag |> str}
           </span>
         );
    initial @ searchResults;
  };

let make =
    (
      ~unselectedTags,
      ~selectedTags,
      ~addTagCB,
      ~removeTagCB,
      ~allowNewTags,
      _children,
    ) => {
  ...component,
  initialState: () => "",
  reducer: (searchString, _state) => ReasonReact.Update(searchString),
  render: ({state, send}) => {
    let results =
      search(
        state,
        send,
        allowNewTags,
        selectedTags,
        unselectedTags,
        addTagCB,
      );
    <div className="mt-2">
      {
        if (selectedTags |> ListUtils.isNotEmpty) {
          <div className="flex flex-wrap">
            {
              selectedTags
              |> List.sort(String.compare)
              |> List.map(tag =>
                   <div
                     key=tag
                     className="flex items-center bg-gray-200 border border-gray-500 rounded-lg mt-1 mr-1 text-xs text-gray-900 overflow-hidden">
                     <span className="px-2 py-px"> {tag |> str} </span>
                     <span
                       title={"Remove tag " ++ tag}
                       className="flex items-center px-2 h-full cursor-pointer px-2 text-gray-700 hover:text-black hover:bg-gray-300 border-l border-gray-400"
                       onClick={_e => handleClick(tag, send, removeTagCB)}>
                       <i className="fas fa-times" />
                     </span>
                   </div>
                 )
              |> Array.of_list
              |> ReasonReact.array
            }
          </div>;
        } else {
          ReasonReact.null;
        }
      }
      <input
        value=state
        onChange={event => send(ReactEvent.Form.target(event)##value)}
        className="appearance-none block bg-white text-gray-800 border border-gray-400 rounded-lg w-full py-3 px-4 mt-2 focus:outline-none focus:bg-white focus:border-gray-500"
        id="tags"
        type_="text"
        placeholder={
          allowNewTags ? "Search for, or add new tags" : "Select tags"
        }
      />
      {
        if (results |> ListUtils.isNotEmpty) {
          <div
            className="flex flex-wrap border border-gray-400 bg-white mt-1 rounded-lg shadow-lg searchable-tag-list__dropdown relative px-4 pt-2 pb-3">
            {results |> Array.of_list |> ReasonReact.array}
          </div>;
        } else {
          ReasonReact.null;
        }
      }
    </div>;
  },
};
