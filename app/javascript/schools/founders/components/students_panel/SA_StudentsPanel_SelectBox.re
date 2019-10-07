let str = ReasonReact.string;

type state = {searchKey: string};

type action =
  | UpdateSearchKey(string);

let component = ReasonReact.reducerComponent("CurriculumEditor__SelectBox");

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
                 className="select-list__item-selected flex justify-between bg-gray-100 text-xs font-semibold border rounded mb-2 ">
                 <div className="p-3 flex-1"> {value |> str} </div>
                 <button
                   className="flex p-3 hover:text-gray-900"
                   onClick={
                     _event => {
                       ReactEvent.Mouse.preventDefault(_event);
                       send(UpdateSearchKey(""));
                       multiSelectCB(_key, value, false);
                     }
                   }>
                   <i className="fas fa-trash-alt text-base" />
                 </button>
               </div>
             )
          |> Array.of_list
          |> ReasonReact.array :
          <div
            className="flex flex-col items-center justify-center bg-gray-100 text-gray-800 rounded px-3 pt-3 ">
            <i className="fas fa-inbox text-3xl" />
            <h5 className="mt-1 font-semibold"> {"None Selected" |> str} </h5>
            <span className="text-xs">
              {"Select from the following list." |> str}
            </span>
          </div>
      }
      {
        nonSelectedList |> List.length > 0 ?
          <div className="flex relative pt-4">
            <div
              className="select-list__group bg-white rounded shadow pb-2 w-full">
              {
                nonSelectedList |> List.length > 3 ?
                  <div className="px-3 pt-3 pb-2">
                    <input
                      className="appearance-none bg-transparent border-b w-full text-gray-800 pb-3 px-2 pl-0 leading-normal focus:outline-none"
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
                    "h-28 overflow-y-scroll" : ""
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
                         className="px-3 py-2 font-semibold hover:bg-primary-100 hover:text-primary-500 cursor-pointer">
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