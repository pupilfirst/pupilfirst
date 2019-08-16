[@bs.config {jsx: 3}];

let str = React.string;

[@react.component]
let make = (~items, ~multiSelectCB) => {
  let (searchKey, setSearchKey) = React.useState(() => "");
  let selectedList =
    items |> List.filter(((_, _, selected)) => selected == true);
  let nonSelectedList =
    items |> List.filter(((_, _, selected)) => selected == false);
  let filteredList =
    switch (nonSelectedList) {
    | [] => []
    | someList =>
      someList
      |> List.filter(((_key, value, _)) =>
           Js.String.includes(
             String.lowercase(searchKey),
             String.lowercase(value),
           )
         )
    };
  <div className="p-6 border rounded bg-gray-100">
    {
      selectedList |> List.length > 0 ?
        selectedList
        |> List.rev
        |> List.map(((_key, value, _)) =>
             <div
               key={_key |> string_of_int}
               className="select-list__item-selected flex items-center justify-between bg-white font-semibold text-xs text-gray-700 border rounded px-3 py-2 mb-2">
               {value |> str}
               <button
                 className="p-1 hover:text-gray-900 focus:otline-none"
                 title="Remove"
                 onClick={
                   _event => {
                     ReactEvent.Mouse.preventDefault(_event);
                     setSearchKey(_ => "");
                     multiSelectCB(_key, value, false);
                   }
                 }>
                 <i className="fas fa-trash-alt text-base" />
               </button>
             </div>
           )
        |> Array.of_list
        |> React.array :
        <div
          className="flex flex-col items-center justify-center bg-gray-100 text-gray-600 rounded px-3 pt-3 ">
          <i className="fas fa-inbox text-3xl" />
          <h5 className="mt-1 font-semibold"> {"None Selected" |> str} </h5>
          <span className="text-xs">
            {"Select from the following list" |> str}
          </span>
        </div>
    }
    {
      nonSelectedList |> List.length > 0 ?
        <div className="flex relative pt-4">
          <div
            className="select-list__group text-sm bg-white rounded shadow pb-2 w-full">
            {
              nonSelectedList |> List.length > 3 ?
                <div className="px-3 pt-3 pb-2">
                  <input
                    className="appearance-none bg-transparent border-b w-full text-gray-700 pb-3 px-2 pl-0 leading-tight focus:outline-none"
                    type_="text"
                    placeholder="Type to Search"
                    onChange={
                      event =>
                        setSearchKey(ReactEvent.Form.target(event)##value)
                    }
                  />
                </div> :
                React.null
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
                           setSearchKey(_ => "");
                           multiSelectCB(_key, value, true);
                         }
                       }
                       title={"Select " ++ value}
                       className="px-3 py-2 font-semibold hover:bg-primary-100 hover:text-primary-500">
                       {value |> str}
                     </div>
                   )
                |> Array.of_list
                |> React.array
              }
            </div>
          </div>
        </div> :
        React.null
    }
  </div>;
};

module Jsx2 = {
  let component =
    ReasonReact.statelessComponent("CurriculumEditor__SelectBox");

  let make = (~items, ~multiSelectCB, children) =>
    ReasonReactCompat.wrapReactForReasonReact(
      make,
      makeProps(~items, ~multiSelectCB, ()),
      children,
    );
};
