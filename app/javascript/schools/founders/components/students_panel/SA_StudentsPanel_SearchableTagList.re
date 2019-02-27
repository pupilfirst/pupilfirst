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

let component = ReasonReact.reducerComponent("SA_StudentsPanel_SearchableTagList");

let make = (~unselectedTags, ~selectedTags, ~addTagCB, ~removeTagCB, _children) => {
  ...component,
  initialState: () => {searchString: "", dropdownVisible: false},
  reducer: (action, state) => {
    switch (action) {
    | UpdateSearchString(searchString) => ReasonReact.Update({...state, searchString})
    | UpdateDropdownVisibility(dropdownVisible) => ReasonReact.Update({...state, dropdownVisible})
    };
  },
  render: ({state, send}) =>
    <div>
      {selectedTags |> List.length == 0 ?
         <div className="text-indigo"> {"None" |> str} </div> :
         <div className="flex">
           {selectedTags
            |> List.sort(String.compare)
            |> List.map(tag => {
                 let buttonClasses = "flex items-center px-2 py-1 rounded-lg mr-1 font-semibold focus:outline-none border border-dashed border-indigo text-white bg-indigo-dark border-transparent";

                 <div key=tag className=buttonClasses>
                   {tag |> str}
                   <i className="material-icons cursor-pointer" onClick={_e => handleClick(tag, send, removeTagCB)}>
                     {"close" |> str}
                   </i>
                 </div>;
               })
            |> Array.of_list
            |> ReasonReact.array}
         </div>}
      <input
        value={state.searchString}
        onChange={event => send(UpdateSearchString(ReactEvent.Form.target(event)##value))}
        onFocus={_e => send(UpdateDropdownVisibility(true))}
        className="appearance-none block bg-white text-grey-darker border border-grey-light rounded py-3 px-4 my-2 focus:outline-none focus:bg-white focus:border-grey"
        id="tag"
        type_="text"
        placeholder="Search or add new..."
      />
      {state.dropdownVisible ?
         <div className="border border-grey-light searchable-tag-list__dropdown pl-4">
           {List.append(selectedTags, unselectedTags)
            |> List.mem(state.searchString)
            || state.searchString
            |> String.length < 1 ?
              ReasonReact.null :
              <div
                onClick={_e => handleClick(state.searchString, send, addTagCB)}
                className="my-3 hover:text-indigo cursor-pointer">
                {state.searchString |> str}
                <span className="text-grey ml-1"> {"(Add New)" |> str} </span>
              </div>}
           {unselectedTags
            |> List.filter(tag => tag |> String.lowercase |> Js.String.includes(state.searchString))
            |> List.sort(String.compare)
            |> List.map(tag =>
                 <div
                   key=tag
                   className="my-3 hover:text-indigo cursor-pointer"
                   onClick={_e => handleClick(tag, send, addTagCB)}>
                   {tag |> str}
                 </div>
               )
            |> Array.of_list
            |> ReasonReact.array}
         </div> :
         ReasonReact.null}
    </div>,
};
