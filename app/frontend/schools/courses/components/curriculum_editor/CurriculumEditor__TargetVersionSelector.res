let str = React.string

let tr = I18n.t(~scope="components.CurriculumEditor__TargetVersionSelector", ...)
let ts = I18n.ts

let handleClick = (setShowDropdown, versions, event) => {
  ReactEvent.Mouse.preventDefault(event)
  if Array.length(versions) > 1 {
    setShowDropdown(showDropdown => !showDropdown)
  }
}

let handleVersionSelect = (setShowDropdown, selectVersionCB, selectedVersion, event) => {
  ReactEvent.Mouse.preventDefault(event)
  setShowDropdown(showDropdown => !showDropdown)
  selectVersionCB(selectedVersion)
}

let handleViewMode = (switchViewModeCB, previewMode, event) => {
  ReactEvent.Mouse.preventDefault(event)
  switchViewModeCB(previewMode)
}

let handleRestoreVersion = (handleRestoreVersionCB, versionOn, event) => {
  ReactEvent.Mouse.preventDefault(event)
  handleRestoreVersionCB(versionOn)
}

let previewModeButtonEnableClass = "bg-primary-100 shadow-inner text-primary-500"

@react.component
let make = (
  ~versions,
  ~selectedVersion,
  ~selectVersionCB,
  ~previewMode,
  ~switchViewModeCB,
  ~handleRestoreVersionCB,
) => {
  let (showDropdown, setShowDropdown) = React.useState(() => false)
  let firstVersion = versions[0]->Option.getExn(~message="Failed to load first version")

  <div className="flex justify-between items-end">
    <div className="w-1/3">
      {selectedVersion == firstVersion
        ? <div className="flex rounded-lg border border-gray-300">
            <button
              onClick={event => handleViewMode(switchViewModeCB, true, event)}
              className={"w-1/2 py-2 px-3 font-semibold rounded-s-lg text-sm focus:outline-none " ++ (
                previewMode
                  ? previewModeButtonEnableClass
                  : "bg-white shadow-md hover:shadow hover:text-primary-500 hover:bg-gray-50"
              )}>
              {str(tr("preview"))}
            </button>
            <button
              onClick={event => handleViewMode(switchViewModeCB, false, event)}
              className={"w-1/2 py-2 px-3 font-semibold rounded-e-lg text-sm focus:outline-none " ++ (
                previewMode
                  ? "bg-white shadow-md hover:shadow hover:text-primary-500 hover:bg-gray-50"
                  : previewModeButtonEnableClass
              )}>
              {str(tr("edit"))}
            </button>
          </div>
        : React.null}
    </div>
    <div className="w-2/3 flex justify-end items-end">
      {selectedVersion == firstVersion
        ? React.null
        : <button
            onClick={event =>
              handleRestoreVersion(handleRestoreVersionCB, Js.Json.string(selectedVersion), event)}
            className="btn btn-warning border border-orange-500 me-4">
            {str(tr("restore_version"))}
          </button>}
      <div className="relative">
        <div className="inline-block">
          <label className="text-xs block text-gray-600 mb-1">
            {str(Array.length(versions) > 1 ? ts("versions") : ts("version"))}
          </label>
          <button
            onClick={event => handleClick(setShowDropdown, versions, event)}
            className={"target-editor__version-dropdown-button text-sm appearance-none bg-white border inline-flex items-center justify-between focus:outline-none font-semibold relative rounded " ++ (
              Array.length(versions) > 1
                ? "px-3 border-gray-300 hover:bg-gray-50 hover:shadow-lg"
                : "border-transparent cursor-auto"
            )}>
            <span className="flex items-center py-2">
              <span className="truncate "> {str(selectedVersion)} </span>
            </span>
            {Array.length(versions) > 1
              ? <span className="ltr:text-right rtl:text-left ps-3 py-2 border-s border-gray-300">
                  <i className="fas fa-chevron-down text-sm" />
                </span>
              : React.null}
          </button>
        </div>
        {showDropdown
          ? <ul
              id="version-selection-list"
              className="target-editor__version-dropdown-list text-sm bg-white font-semibold border border-gray-300 mt-1 shadow-lg rounded-lg border absolute overflow-auto h-auto w-full z-20">
              {versions
              ->Array.filter(version => version != selectedVersion)
              ->Array.map(version =>
                <li
                  id=version
                  key=version
                  onClick={event =>
                    handleVersionSelect(setShowDropdown, selectVersionCB, version, event)}
                  className="target-editor__version-dropdown-list-item flex justify-between whitespace-nowrap px-3 py-2 cursor-pointer hover:bg-gray-50 hover:text-primary-500">
                  {str(version)}
                </li>
              )
              ->React.array}
            </ul>
          : React.null}
      </div>
    </div>
  </div>
}
