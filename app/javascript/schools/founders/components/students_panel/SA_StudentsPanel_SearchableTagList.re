let str = ReasonReact.string;

type state = {
  searchString: string,
  dropdownVisible: bool,
};

type action =
  | UpdateSearchString(string)
  | UpdateDropdownVisibility(bool);

let handleClick = (tag, send, clickCB) => {
  clickCB(tag);
  send(UpdateSearchString(""));
  send(UpdateDropdownVisibility(false));
};

let component =
  ReasonReact.reducerComponent("SA_StudentsPanel_SearchableTagList");

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
  initialState: () => {searchString: "", dropdownVisible: false},
  reducer: (action, state) =>
    switch (action) {
    | UpdateSearchString(searchString) =>
      ReasonReact.Update({...state, searchString})
    | UpdateDropdownVisibility(dropdownVisible) =>
      ReasonReact.Update({...state, dropdownVisible})
    },
  render: ({state, send}) =>
    <div className="mt-2">
      {
        selectedTags |> List.length == 0 ?
          ReasonReact.null :
          <div className="flex">
            {
              selectedTags
              |> List.sort(String.compare)
              |> List.map(tag =>
                   <div
                     key=tag
                     className="flex items-center px-2 py-1 border rounded-lg mr-1 text-sm font-semibold focus:outline-none bg-grey-light">
                     {tag |> str}
                     <i
                       className="material-icons cursor-pointer text-sm ml-1"
                       onClick={_e => handleClick(tag, send, removeTagCB)}>
                       {"close" |> str}
                     </i>
                   </div>
                 )
              |> Array.of_list
              |> ReasonReact.array
            }
          </div>
      }
      <input
        value={state.searchString}
        onChange={
          event =>
            send(UpdateSearchString(ReactEvent.Form.target(event)##value))
        }
        onFocus={_e => send(UpdateDropdownVisibility(true))}
        onBlur={_e => send(UpdateDropdownVisibility(false))}
        className="appearance-none block bg-white text-grey-darker border border-grey-light rounded-lg w-full py-3 px-4 mt-2 focus:outline-none focus:bg-white focus:border-grey"
        id="tag"
        type_="text"
        placeholder={allowNewTags ? "Search or add new..." : "Select tags"}
      />
      {
        state.dropdownVisible ?
          <div
            className="border border-grey-light bg-white mt-3 rounded-lg max-w-xs searchable-tag-list__dropdown relative px-4 py-2">
            {
              !allowNewTags
              || List.append(selectedTags, unselectedTags)
              |> List.mem(state.searchString)
              || state.searchString
              |> String.length < 1 ?
                ReasonReact.null :
                <div
                  onMouseDown={
                    _e => handleClick(state.searchString, send, addTagCB)
                  }
                  className="my-3 text-sm hover:text-indigo cursor-pointer">
                  {state.searchString |> str}
                  <span className="text-grey ml-1">
                    {"(Add New)" |> str}
                  </span>
                </div>
            }
            {
              unselectedTags
              |> List.filter(tag =>
                   tag
                   |> String.lowercase
                   |> Js.String.includes(state.searchString)
                 )
              |> List.sort(String.compare)
              |> List.map(tag =>
                   <div
                     key=tag
                     className="my-3 text-sm hover:text-indigo cursor-pointer"
                     onMouseDown={_e => handleClick(tag, send, addTagCB)}>
                     {tag |> str}
                   </div>
                 )
              |> Array.of_list
              |> ReasonReact.array
            }
          </div> :
          ReasonReact.null
      }
    </div>,
};