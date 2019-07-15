let str = ReasonReact.string;

type state = {searchKey: string};

type action =
  | UpdateSearchKey(string);

let component = ReasonReact.reducerComponent("SA_Coaches__SelectBox");

let make = (~items, ~multiSelectCB, _children) => {
  ...component,
  initialState: () => {searchKey: ""},
  reducer: (action, _state) =>
    switch (action) {
    | UpdateSearchKey(searchKey) =>
      ReasonReact.Update({searchKey: searchKey})
    },
  render: ({state, send}) => {
    let selectedList =
      items |> List.filter(((_, _, selected)) => selected == true);
    let nonSelectedList =
      items |> List.filter(((_, _, selected)) => selected == false);
    let filteredList =
      nonSelectedList
      |> List.filter(((_key, value, _)) =>
           Js.String.includes(
             String.lowercase(state.searchKey),
             String.lowercase(value),
           )
         );
    <div>
      {
        selectedList |> List.length > 0 ?
          selectedList
          |> List.rev
          |> List.map(((_key, value, _)) =>
               <div
                 key={_key |> string_of_int}
                 className="select-list__item-selected flex items-center justify-between bg-gray-100 text-xs text-gray-600 border rounded p-3 mb-2">
                 {value |> str}
                 <button
                   onClick={
                     _event => {
                       ReactEvent.Mouse.preventDefault(_event);
                       send(UpdateSearchKey(""));
                       multiSelectCB(_key, value, false);
                     }
                   }>
                   <Icon.Jsx2 kind=Icon.Delete size="4" opacity=75 />
                 </button>
               </div>
             )
          |> Array.of_list
          |> ReasonReact.array :
          <div
            className="flex items-center justify-between bg-gray-100 text-xs text-gray-600 border rounded p-3 mb-2">
            {"None Selected" |> str}
          </div>
      }
      {
        nonSelectedList |> List.length > 0 ?
          <div className="flex relative">
            <div
              className="select-list__group bg-white border rounded rounded-t-none shadow pb-2 w-full">
              {
                nonSelectedList |> List.length > 3 ?
                  <div className="px-3 pt-3 pb-2">
                    <input
                      className="appearance-none bg-transparent border-b w-full text-gray-800 pb-3 px-2 pl-0 leading-tight focus:outline-none"
                      type_="text"
                      placeholder="Type to Search and Add Coach"
                      onChange={
                        event =>
                          send(
                            UpdateSearchKey(
                              ReactEvent.Form.target(event)##value,
                            ),
                          )
                      }
                    />
                  </div> :
                  ReasonReact.null
              }
              <div
                className={
                  nonSelectedList |> List.length > 3 ?
                    "h-24 overflow-y-scroll" : ""
                }>
                {
                  filteredList
                  |> List.map(((_key, value, _)) =>
                       <div
                         key={_key |> string_of_int}
                         onClick={
                           _event => {
                             ReactEvent.Mouse.preventDefault(_event);
                             send(UpdateSearchKey(""));
                             multiSelectCB(_key, value, true);
                           }
                         }
                         className="px-3 py-2 hover:bg-gray-200">
                         {value |> str}
                       </div>
                     )
                  |> Array.of_list
                  |> ReasonReact.array
                }
              </div>
            </div>
          </div> :
          ReasonReact.null
      }
    </div>;
  },
};