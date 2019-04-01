let str = ReasonReact.string;

type state = {searchString: string};

type action =
  | UpdateSearchString(string);

let handleClick = (tag, send, clickCB) => {
  clickCB(tag);
  send(UpdateSearchString(""));
};

let component =
  ReasonReact.reducerComponent("SA_StudentsPanel_SearchableTagList");

let search =
    (state, send, allowNewTags, selectedTags, unselectedTags, addTagCB) =>
  switch (state.searchString) {
  | "" => []
  | searchString =>
    let allTags = List.append(selectedTags, unselectedTags);
    /* If addition of tag is allowed, and it IS new, then display that option at the front. */
    let initial =
      if (allowNewTags && ! (allTags |> List.mem(searchString))) {
        [
          <span
            title=("Add new tag " ++ searchString)
            key=searchString
            onMouseDown=(_e => handleClick(searchString, send, addTagCB))
            className="p-2 text-sm hover:text-indigo cursor-pointer">
            (searchString |> str)
            <span className="text-grey"> (" (New)" |> str) </span>
          </span>,
        ];
      } else {
        [];
      };
    let searchResults =
      unselectedTags
      |> List.filter(tag =>
           tag |> String.lowercase |> Js.String.includes(state.searchString)
         )
      |> List.sort(String.compare)
      |> List.map(tag =>
           <span
             title=("Pick tag " ++ tag)
             key=tag
             className="p-2 text-sm hover:text-indigo cursor-pointer"
             onMouseDown=(_e => handleClick(tag, send, addTagCB))>
             (tag |> str)
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
  initialState: () => {searchString: ""},
  reducer: (action, state) =>
    switch (action) {
    | UpdateSearchString(searchString) =>
      ReasonReact.Update({searchString: searchString})
    },
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
      (
        if (selectedTags |> ListUtils.isNotEmpty) {
          <div className="flex">
            (
              selectedTags
              |> List.sort(String.compare)
              |> List.map(tag =>
                   <div
                     key=tag
                     className="flex items-center pl-2 border rounded-lg mr-1 text-sm font-semibold focus:outline-none bg-grey-light">
                     <span> (tag |> str) </span>
                     <span
                       title=("Remove tag " ++ tag)
                       className="cursor-pointer p-2"
                       onClick=(_e => handleClick(tag, send, removeTagCB))>
                       <Icon kind=Icon.Close size="3" />
                     </span>
                   </div>
                 )
              |> Array.of_list
              |> ReasonReact.array
            )
          </div>;
        } else {
          ReasonReact.null;
        }
      )
      <input
        value=state.searchString
        onChange=(
          event =>
            send(UpdateSearchString(ReactEvent.Form.target(event)##value))
        )
        className="appearance-none block bg-white text-grey-darker border border-grey-light rounded-lg w-full py-3 px-4 mt-2 focus:outline-none focus:bg-white focus:border-grey"
        id="tags"
        type_="text"
        placeholder=(
          allowNewTags ? "Search for, or add new tags" : "Select tags"
        )
      />
      (
        if (results |> ListUtils.isNotEmpty) {
          <div
            className="border border-grey-light bg-white mt-3 rounded-lg max-w-xs searchable-tag-list__dropdown relative px-4 py-2">
            (results |> Array.of_list |> ReasonReact.array)
          </div>;
        } else {
          ReasonReact.null;
        }
      )
    </div>;
  },
};