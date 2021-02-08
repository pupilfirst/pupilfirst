%bs.raw(`require("./MultiselectDropdown.css")`)

let str = React.string

module DomUtils = {
  exception RootElementMissing(string)
  open Webapi.Dom
  let focus = id =>
    (switch document |> Document.getElementById(id) {
    | Some(el) => el
    | None => raise(RootElementMissing(id))
    } |> Element.asHtmlElement)->Belt.Option.map(HtmlElement.focus) |> ignore
}

module type Selectable = {
  type t
  let label: t => option<string>
  let value: t => string
  let searchString: t => string
  let color: t => string
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

  let selectionTitle = selection => {
    let value = selection |> Selectable.value
    switch selection |> Selectable.label {
    | Some(label) => "Pick " ++ (label ++ (": " ++ value))
    | None => "Pick " ++ value
    }
  }

  let tagPillClasses = (color, showHover) => {
    let bgColor200 = "bg-" ++ (color ++ "-200 ")
    let bgColor300 = "bg-" ++ (color ++ "-300 ")
    let textColor800 = "text-" ++ (color ++ "-800 ")
    let textColor900 = "text-" ++ (color ++ "-900 ")

    "rounded text-xs overflow-hidden " ++
    (bgColor200 ++
    (textColor800 ++ (
      showHover ? "px-2 py-px hover:" ++ (bgColor300 ++ ("hover:" ++ textColor900)) : "inline-flex"
    )))
  }

  let applyFilter = (selection, onSelect, id, event) => {
    event |> ReactEvent.Mouse.preventDefault

    onSelect(selection)
    DomUtils.focus(id)
  }

  let showOptions = (options, onSelect, id, labelSuffix) =>
    options |> Array.mapi((index, selection) =>
      <button
        key={index |> string_of_int}
        title={selectionTitle(selection)}
        className="flex text-xs px-4 py-1 items-center w-full hover:bg-gray-200 focus:outline-none focus:bg-gray-200"
        onClick={applyFilter(selection, onSelect, id)}>
        {switch selection |> Selectable.label {
        | Some(label) =>
          <span className="mr-2 flex-shrink-0 md:w-1/6 text-right">
            {label ++ labelSuffix |> str}
          </span>
        | None => React.null
        }}
        <span className={tagPillClasses(selection |> Selectable.color, true)}>
          {selection |> Selectable.value |> str}
        </span>
      </button>
    )

  let searchResult = (searchInput, unselected, labelSuffix, id, onSelect) => {
    // Remove all excess space characters from the user input.
    let normalizedString =
      searchInput
      |> Js.String.trim
      |> Js.String.replaceByRe(Js.Re.fromStringWithFlags("\\s+", ~flags="g"), " ")

    let options = switch normalizedString {
    | "" => []
    | searchString => search(searchString, unselected)
    }

    showOptions(options, onSelect, id, labelSuffix)
  }

  let removeSelection = (onDeselect, selection, event) => {
    event |> ReactEvent.Mouse.preventDefault

    onDeselect(selection)
  }

  let showSelected = (onDeselect, labelSuffix, selected) =>
    selected |> Array.mapi((index, selection) => {
      let value = selection |> Selectable.value
      <div key={index |> string_of_int} className="inline-flex py-1 mr-2">
        <div className={tagPillClasses(selection |> Selectable.color, false)}>
          <span className="pl-2 py-px">
            {switch selection |> Selectable.label {
            | Some(label) => label ++ (labelSuffix ++ value)
            | None => value
            } |> str}
          </span>
          <button
            title={"Remove selection: " ++ value}
            className="ml-1 text-red-700 px-2 py-px focus:outline-none hover:bg-red-400 hover:text-white flex items-center"
            onClick={removeSelection(onDeselect, selection)}>
            <PfIcon className="if i-times-light" />
          </button>
        </div>
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
      className="multiselect-dropdown__search-dropdown w-full absolute border border-gray-400 bg-white mt-1 rounded-lg shadow-lg py-2 z-50">
      <p className="text-gray-700 italic mx-4 text-xs border-b pb-1 mb-2">
        {str("Suggestions:")}
      </p>
      children
    </div>

  let showHint = hint =>
    <p
      className="font-normal text-xs px-4 py-2 -mb-2 rounded-b-lg bg-gray-100 mt-2 text-left border-t">
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
        Webapi.Dom.Window.removeEventListener("click", curriedFunction, Webapi.Dom.window)

      if showDropdown {
        Webapi.Dom.Window.addEventListener("click", curriedFunction, Webapi.Dom.window)
        Some(removeEventListener)
      } else {
        removeEventListener()
        None
      }
    }, [showDropdown])

    let results = searchResult(value, unselected, labelSuffix, inputId, onSelect)
    <div className="w-full relative">
      <div>
        <div
          className="flex flex-wrap items-center text-sm bg-white border border-gray-400 rounded w-full py-1 px-3 mt-1 focus:outline-none focus:bg-white focus:border-primary-300">
          {selected |> showSelected(onDeselect, labelSuffix) |> React.array}
          <input
            onClick={_ => setShowDropdown(s => !s)}
            autoComplete="off"
            value
            onChange={e => onChange(ReactEvent.Form.target(e)["value"])}
            className="flex-grow appearance-none bg-transparent border-none text-gray-700 mr-3 py-1 leading-snug focus:outline-none"
            id=inputId
            type_="search"
            placeholder
          />
        </div>
      </div>
      <div />
      {switch (showDropdown, results, defaultOptions, hint) {
      | (false, results, _options, _hint) =>
        switch (value, results) {
        | ("", _) => React.null
        | (_value, []) => wrapper(str(emptyMessage))
        | (_value, results) => wrapper(React.array(results))
        }
      | (true, [], [], None) => value == "" ? React.null : wrapper(str(emptyMessage))
      | (true, [], [], Some(hint)) => wrapper(showHint(hint))
      | (true, [], options, None) =>
        wrapper(React.array(showOptions(options, onSelect, inputId, labelSuffix)))
      | (true, [], options, Some(hint)) =>
        wrapper(
          <div>
            {React.array(showOptions(options, onSelect, inputId, labelSuffix))} {showHint(hint)}
          </div>,
        )
      | (true, results, _options, _hint) => wrapper(React.array(results))
      }}
    </div>
  }
}
