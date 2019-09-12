[@bs.config {jsx: 3}];

let str = React.string;

let handleClick = (setShowDropdown, versions, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  if (versions |> Array.length > 1) {
    setShowDropdown(showDropdown => !showDropdown);
  };
};

let handleVersionSelect =
    (setShowDropdown, selectVersionCB, selectedVersion, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setShowDropdown(showDropdown => !showDropdown);
  selectVersionCB(selectedVersion);
};

let handleViewMode = (switchViewModeCB, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  switchViewModeCB();
};

let handleRestoreVersion = (handleRestoreVersionCB, versionOn, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  handleRestoreVersionCB(versionOn);
};

[@react.component]
let make =
    (
      ~versions,
      ~selectedVersion,
      ~selectVersionCB,
      ~previewMode,
      ~switchViewModeCB,
      ~handleRestoreVersionCB,
    ) => {
  let (showDropdown, setShowDropdown) = React.useState(() => false);
  <div className="flex justify-between items-end">
    <div className="flex items-end">
      <div className="relative">
        <div className="inline-block">
          <label className="text-xs block text-gray-600 mb-1">
            {(versions |> Array.length > 1 ? "Versions" : "Version") |> str}
          </label>
          <button
            onClick={handleClick(setShowDropdown, versions)}
            className="target-editor__version-dropdown-button appearance-none bg-orange-100 border border-orange-400 inline-flex items-center justify-between hover:bg-orange-200 hover:shadow-lg hover:text-orange-800 focus:outline-none focus:bg-orange-200 font-semibold relative rounded">
            <span className="flex items-center px-3 py-2">
              <span className="truncate text-left">
                {
                  selectedVersion
                  |> DateTime.stingToFormatedTime(DateTime.OnlyDate)
                  |> str
                }
              </span>
            </span>
            {
              versions |> Array.length > 1 ?
                <span
                  className="text-right px-3 py-2 border-l border-orange-400">
                  <i className="fas fa-chevron-down text-sm" />
                </span> :
                React.null
            }
          </button>
        </div>
        {
          showDropdown ?
            <ul
              id="version-selection-list"
              className="target-editor__version-dropdown-list bg-orange-100 font-semibold border border-orange-400 mt-1 shadow-lg rounded-lg border absolute overflow-auto h-auto w-full z-20">
              {
                versions
                |> Array.to_list
                |> List.filter(version => version != selectedVersion)
                |> List.map(version =>
                     <li
                       id=version
                       key=version
                       onClick={
                         handleVersionSelect(
                           setShowDropdown,
                           selectVersionCB,
                           version,
                         )
                       }
                       className="target-editor__version-dropdown-list-item flex justify-between whitespace-no-wrap px-3 py-3 cursor-pointer hover:bg-orange-200 hover:text-orange-800">
                       {
                         version
                         |> DateTime.stingToFormatedTime(DateTime.OnlyDate)
                         |> str
                       }
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
          <button
            onClick={
              handleRestoreVersion(
                handleRestoreVersionCB,
                selectedVersion |> Js.Json.string,
              )
            }
            className="btn btn-warning border border-orange-500 ml-4">
            {"Restore this version" |> str}
          </button>
      }
    </div>
    {
      selectedVersion == versions[0] ?
        <button
          onClick={handleViewMode(switchViewModeCB)}
          className="btn btn-default border border-transparent ml-4">
          {(previewMode ? "Edit" : "Preview") |> str}
        </button> :
        React.null
    }
  </div>;
};
