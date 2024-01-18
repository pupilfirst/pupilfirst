%%raw(`import "./MultiselectDropdown.css"`)

module type Selectable = {
  type t
  let label: t => option<string>
  let value: t => string
  let searchString: t => string
  let color: t => string
}

type searchItem = {
  index: int,
  text: string,
}

@module("../utils/fuzzySearch")
external fuzzySearch: (string, array<searchItem>) => array<searchItem> = "default"

let str = React.string

module DomUtils = {
  exception RootElementMissing(string)
  open Webapi.Dom
  let focus = id =>
    (switch document->Document.getElementById(id) {
    | Some(el) => el
    | None => raise(RootElementMissing(id))
    } |> Element.asHtmlElement)->Belt.Option.map(HtmlElement.focus) |> ignore
}

module Make = (Selectable: Selectable) => {
  let search = (searchString, selections) => {
    let searchSelection =
      selections->Js.Array2.mapi((s, i) => {index: i, text: Selectable.searchString(s)})
    let results = fuzzySearch(String.lowercase_ascii(searchString), searchSelection)
    results->Js.Array2.map(searchItem => selections[searchItem.index])
  }

  let selectionTitle = selection => {
    let value = selection |> Selectable.value
    switch selection |> Selectable.label {
    | Some(label) => "Pick " ++ (label ++ (": " ++ value))
    | None => "Pick " ++ value
    }
  }

  let tagPillClasses = (color, showHover) => {
    let bgColor = switch color {
    | "primary" => "bg-primary-100"
    | "orange" => "bg-orange-100"
    | "green" => "bg-green-100"
    | "red" => "bg-red-100"
    | "yellow" => "bg-yellow-100"
    | "blue" => "bg-blue-100"
    | "gray" => "bg-gray-100"
    | "focusColor" => "bg-focusColor-100"
    | _ => "bg-orange-100"
    }

    let textColor = switch color {
    | "primary" => "text-primary-800"
    | "orange" => "text-orange-800"
    | "green" => "text-green-800"
    | "red" => "text-red-800"
    | "yellow" => "text-yellow-800"
    | "blue" => "text-blue-800"
    | "gray" => "text-gray-800"
    | "focusColor" => "text-focusColor-800"
    | _ => "text-orange-800"
    }

    "rounded text-sm  font-semibold overflow-hidden " ++
    (bgColor ++
    " " ++
    textColor ++
    " " ++
    (showHover ? "px-2 py-px hover:saturate-50 focus:saturate-50" : "inline-flex"))
  }

  let applyFilter = (selection, onSelect, id, event) => {
    event |> ReactEvent.Mouse.preventDefault

    onSelect(selection)
    DomUtils.focus(id)
  }

  let showOptions = (options, onSelect, id, labelSuffix, loading) => {
    loading
      ? [
          <div className="px-4">
            <div className="px-4">
              <div className="skeleton-body-container w-full pb-4 mx-auto">
                <div className="skeleton-body-wrapper px-3 lg:px-0">
                  <div className="skeleton-placeholder__line-sm mt-4 w-1/2 skeleton-animate" />
                  <div className="skeleton-placeholder__line-sm mt-4 w-3/4 skeleton-animate" />
                </div>
              </div>
            </div>
          </div>,
        ]
      : options |> Array.mapi((index, selection) =>
          <button
            key={index |> string_of_int}
            title={selectionTitle(selection)}
            ariaLabel={Selectable.searchString(selection)}
            className="flex text-sm px-4 py-1 items-center w-full hover:bg-gray-50 focus:outline-none focus:bg-gray-50"
            onClick={applyFilter(selection, onSelect, id)}>
            {switch selection |> Selectable.label {
            | Some(label) =>
              <span className="me-2 shrink-0 w-1/3 sm:w-auto md:w-1/3 ltr:text-right rtl:text-left">
                {label ++ labelSuffix |> str}
              </span>
            | None => React.null
            }}
            <span className={tagPillClasses(selection |> Selectable.color, true)}>
              {selection |> Selectable.value |> str}
            </span>
          </button>
        )
  }

  let searchResult = (searchInput, unselected, labelSuffix, loading, id, onSelect) => {
    // Remove all excess space characters from the user input.
    let normalizedString =
      searchInput
      |> Js.String.trim
      |> Js.String.replaceByRe(Js.Re.fromStringWithFlags("\\s+", ~flags="g"), " ")

    let options = switch normalizedString {
    | "" => []
    | searchString => search(searchString, unselected)
    }

    showOptions(options, onSelect, id, labelSuffix, loading)
  }

  let removeSelection = (onDeselect, selection, event) => {
    event |> ReactEvent.Mouse.preventDefault

    onDeselect(selection)
  }

  let showSelected = (onDeselect, labelSuffix, selected) =>
    selected |> Array.mapi((index, selection) => {
      let value = selection |> Selectable.value
      <div
        key={index |> string_of_int}
        className={tagPillClasses(selection |> Selectable.color, false) ++ " "}>
        <span className="px-2 py-px text-xs leading-[unset]">
          {switch selection |> Selectable.label {
          | Some(label) => label ++ (labelSuffix ++ value)
          | None => value
          } |> str}
        </span>
        <button
          ariaLabel={"Remove selection: " ++ value}
          title={"Remove selection: " ++ value}
          className="bg-gray-200 text-red-700 px-2 py-px text-xs focus:outline-none hover:bg-red-400 hover:text-white flex items-center focus:bg-red-400 focus:text-white"
          onClick={removeSelection(onDeselect, selection)}>
          <PfIcon className="if i-times-regular" />
        </button>
      </div>
    })

  let onWindowClick = (showDropdown, setShowDropdown, _event) =>
    if showDropdown {
      setShowDropdown(_ => false)
    } else {
      ()
    }

  let toggleDropdown = (setShowDropdown, event) => {
    event |> ReactEvent.Mouse.stopPropagation
    setShowDropdown(showDropdown => !showDropdown)
  }

  let wrapper = children =>
    <div
      role="listbox"
      className="multiselect-dropdown__search-dropdown w-full absolute border border-gray-300 bg-white mt-1 rounded-lg shadow-lg py-2 z-50">
      <p className="text-gray-600 italic mx-4 text-xs border-b pb-1 mb-2">
        {str("Suggestions:")}
      </p>
      children
    </div>

  let showHint = hint =>
    <p className="font-normal text-xs px-4 py-2 -mb-2 rounded-b-lg bg-gray-50 mt-2  border-t">
      {str(hint)}
    </p>

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
    ~labelSuffix=": ",
    ~emptyMessage="No results found",
    ~hint=?,
    ~defaultOptions=[],
    ~loading=false,
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

    let (showDropdown, setShowDropdown) = React.useState(() => false)

    React.useEffect1(() => {
      let curriedFunction = onWindowClick(showDropdown, setShowDropdown)

      let removeEventListener = () =>
        Webapi.Dom.Window.removeEventListener(Webapi.Dom.window, "click", curriedFunction)

      if showDropdown {
        Webapi.Dom.Window.addEventListener(Webapi.Dom.window, "click", curriedFunction)
        Some(removeEventListener)
      } else {
        removeEventListener()
        None
      }
    }, [showDropdown])

    let results = searchResult(value, unselected, labelSuffix, loading, inputId, onSelect)
    <div className="w-full relative">
      <div>
        <div
          className="bg-gray-50 flex flex-wrap gap-2 items-center text-sm bg-white border border-gray-300 rounded-md w-full p-3 focus-within:ring-2 focus-within:ring-inset focus-within:ring-focusColor-500">
          {selected |> showSelected(onDeselect, labelSuffix) |> React.array}
          <input
            onClick={_ => setShowDropdown(s => !s)}
            autoComplete="off"
            value
            onChange={e => onChange(ReactEvent.Form.target(e)["value"])}
            className="flex-1 grow appearance-none bg-transparent border-none text-gray-600 leading-snug focus:outline-none placeholder-gray-500"
            id=inputId
            type_="search"
            role="combobox"
            placeholder
          />
        </div>
      </div>
      <div />
      {switch (showDropdown, results, defaultOptions, hint) {
      | (false, results, _options, _hint) =>
        switch (Js.String.trim(value), results) {
        | ("", _) => React.null
        | (_value, []) => wrapper(str(emptyMessage))
        | (_value, results) => wrapper(React.array(results))
        }
      | (true, [], [], None) => value == "" ? React.null : wrapper(str(emptyMessage))
      | (true, [], [], Some(hint)) => wrapper(showHint(hint))
      | (true, [], options, None) =>
        wrapper(React.array(showOptions(options, onSelect, inputId, labelSuffix, loading)))
      | (true, [], options, Some(hint)) =>
        wrapper(
          <div>
            {React.array(showOptions(options, onSelect, inputId, labelSuffix, loading))}
            {showHint(hint)}
          </div>,
        )
      | (true, results, _options, _hint) => wrapper(React.array(results))
      }}
    </div>
  }
}
