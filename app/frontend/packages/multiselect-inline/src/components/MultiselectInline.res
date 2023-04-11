%%raw(`import "./MultiselectInline.css"`)

let str = React.string

module type Selectable = {
  type t
  let value: t => string
  let searchString: t => string
}

module Make = (Selectable: Selectable) => {
  let search = (searchString, selections) =>
    (selections |> Js.Array.filter(selection =>
      selection
      |> Selectable.searchString
      |> String.lowercase_ascii
      |> Js.String.includes(searchString |> String.lowercase_ascii)
    ))
      ->Belt.SortArray.stableSortBy((x, y) =>
        String.compare(x |> Selectable.value, y |> Selectable.value)
      )

  let searchUnselected = (searchInput, unselectedData) => {
    let normalizedString =
      searchInput
      |> Js.String.trim
      |> Js.String.replaceByRe(Js.Re.fromStringWithFlags("\\s+", ~flags="g"), " ")
    switch normalizedString {
    | "" => unselectedData
    | searchString => unselectedData |> search(searchString)
    }
  }

  let borderColor = colorForSelected => "border border-" ++ (colorForSelected ++ "-500")

  let getBgColor = colorForSelected =>
    switch colorForSelected {
    | "primary" => "bg-primary-200"
    | "orange" => "bg-orange-200"
    | "green" => "bg-green-200"
    | "red" => "bg-red-200"
    | "yellow" => "bg-yellow-200"
    | "blue" => "bg-blue-200"
    | "gray" => "bg-gray-200"
    | "focusColor" => "bg-focusColor-200"
    | _ => "bg-orange-200"
    }

  let selectedItemClasses = colorForSelected =>
    getBgColor(colorForSelected) ++ " " ++ borderColor(colorForSelected)

  let searchVisible = (unselected, value) => value != "" || unselected |> Array.length > 3

  @react.component
  let make = (
    ~id=?,
    ~placeholder="Search",
    ~onChange,
    ~value,
    ~unselected,
    ~selected,
    ~onSelect,
    ~onDeselect,
    ~emptySelectionMessage="No items selected",
    ~allItemsSelectedMessage="You have selected all items!",
    ~colorForSelected="orange",
  ) => {
    let (inputId, _setId) = React.useState(() =>
      switch id {
      | Some(id) => id
      | None =>
        "re-multiselect-" ++
        ((Js.Date.now() |> Js.Float.toString) ++
        ("-" ++ (Js.Math.random_int(100000, 999999) |> string_of_int)))
      }
    )

    let searchResults = searchUnselected(value, unselected)
    let showSearchForm = searchVisible(unselected, value)

    <div className="p-6 border rounded bg-gray-50">
      <div>
        {selected |> Array.length > 0
          ? selected
            |> Array.mapi((index, selected) =>
              <span
                key={index |> string_of_int}
                className={"inline-flex items-center font-semibold text-xs mb-2 me-2 rounded-full overflow-hidden " ++
                selectedItemClasses(colorForSelected)}>
                <span className="px-2 py-1 flex-1"> {selected |> Selectable.value |> str} </span>
                <button
                  className={"inline-flex shrink-0 px-2 py-1 text-sm border-s-0 rounded-e items-center text-gray-800 hover:bg-gray-50 hover:text-red-500 focus:outline-none focus:bg-gray-50 focus:text-red-500 " ++
                  borderColor(colorForSelected)}
                  title={"Remove " ++ Selectable.value(selected)}
                  onClick={event => {
                    ReactEvent.Mouse.preventDefault(event)

                    onDeselect(selected)
                  }}>
                  <PfIcon className="if i-times-regular" />
                </button>
              </span>
            )
            |> React.array
          : <div
              className="flex flex-col items-center justify-center bg-gray-50 text-gray-800 rounded px-3 pt-3 ">
              <i className="fas fa-inbox text-3xl" />
              <h5 className="mt-1 font-semibold"> {emptySelectionMessage |> str} </h5>
            </div>}
        <div className="text-sm font-medium border-t pt-2 mt-2">
          {(
            unselected |> Array.length > 0
              ? "Add more from the list below:"
              : allItemsSelectedMessage
          ) |> str}
        </div>
      </div>
      {unselected |> Array.length > 0
        ? <div className="flex relative pt-3">
            <div
              className={"text-sm bg-white rounded shadow w-full" ++ (
                showSearchForm ? " pb-2" : ""
              )}>
              {showSearchForm
                ? <div className="px-3 pt-3 pb-2">
                    <input
                      id=inputId
                      className="appearance-none bg-transparent border-b w-full text-gray-600 pb-3 px-2 ps-0 leading-normal focus:outline-none"
                      type_="text"
                      value
                      placeholder
                      onChange={event => onChange(ReactEvent.Form.target(event)["value"])}
                    />
                  </div>
                : React.null}
              <div className={showSearchForm ? "multiselect-inline__list overflow-y-scroll" : ""}>
                {searchResults
                |> Array.mapi((index, item) =>
                  <button
                    key={index |> string_of_int}
                    onClick={_event => {
                      ReactEvent.Mouse.preventDefault(_event)
                      onSelect(item)
                    }}
                    ariaLabel={"Select " ++ (item |> Selectable.value)}
                    title={"Select " ++ (item |> Selectable.value)}
                    className="flex w-full multiselect-inline__list-item  items-center px-3 py-2 font-medium hover:bg-primary-100 hover:text-primary-500 focus:outline-none focus:bg-primary-100 focus:text-primary-500 cursor-pointer">
                    <i
                      className="far fa-square multiselect-inline__list-item-select-icon-unselected text-gray-400 text-xl"
                    />
                    <i
                      className="far fa-plus-square multiselect-inline__list-item-select-icon-selected text-xl"
                    />
                    <span className="ms-2"> {item |> Selectable.value |> str} </span>
                  </button>
                )
                |> React.array}
              </div>
            </div>
          </div>
        : React.null}
    </div>
  }
}
