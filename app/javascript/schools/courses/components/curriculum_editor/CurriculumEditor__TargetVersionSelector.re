[@bs.config {jsx: 3}];

let str = React.string;

let handleClick = (setShowDropdown, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setShowDropdown(showDropdown => !showDropdown);
};

let handleVersionSelect =
    (setShowDropdown, selectVersionCB, selectedVersion, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setShowDropdown(showDropdown => !showDropdown);
  selectVersionCB(selectedVersion);
};

[@react.component]
let make = (~versions, ~selectedVersion, ~selectVersionCB) => {
  let (showDropdown, setShowDropdown) = React.useState(() => false);
  <div className="flex justify-between items-end">
    <div className="flex items-end">
      <div className="relative">
        <div className="inline-block">
          <button
            onClick={handleClick(setShowDropdown)}
            className="target-editor__version-dropdown-button appearance-none bg-orange-100 border border-orange-400 inline-flex items-center justify-between hover:bg-orange-200 hover:shadow-lg hover:text-orange-800 focus:outline-none focus:bg-orange-200 font-semibold relative rounded">
            <span className="flex items-center px-3 py-2">
              <span className="truncate text-left">
                {selectedVersion |> str}
              </span>
            </span>
            <span className="text-right px-3 py-2 border-l border-orange-400">
              <i className="fas fa-chevron-down text-sm" />
            </span>
          </button>
        </div>
        {
          showDropdown ?
            <ul
              className="target-editor__version-dropdown-list bg-orange-100 font-semibold border border-orange-400 mt-1 shadow-lg rounded-lg border absolute overflow-auto h-auto w-full z-20">
              {
                versions
                |> Array.to_list
                |> List.filter(version => version != selectedVersion)
                |> List.map(version =>
                     <li
                       key=version
                       onClick={
                         handleVersionSelect(
                           setShowDropdown,
                           selectVersionCB,
                           version,
                         )
                       }
                       className="target-editor__version-dropdown-list-item flex justify-between whitespace-no-wrap px-3 py-3 cursor-pointer hover:bg-orange-200 hover:text-orange-800">
                       {version |> str}
                       <span
                         className="target-editor__version-dropdown-list-item-button px-2 py-px border bg-white ml-3 rounded text-xs border-orange-400 invisible">
                         {"View" |> str}
                       </span>
                     </li>
                   )
                |> Array.of_list
                |> React.array
              }
            </ul> :
            React.null
        }
      </div>
      {
        selectedVersion == versions[0] ?
          React.null :
          <button className="btn btn-warning border border-orange-500 ml-4">
            {"Restore to this version" |> str}
          </button>
      }
    </div>
    {
      selectedVersion == versions[0] ?
        <button className="btn btn-default border border-transparent ml-4">
          {"Edit" |> str}
        </button> :
        React.null
    }
  </div>;
};
