module type Selectable = {
  type t

  let name: t => string
}

module Make = (Selectable: Selectable) => {
  let showSelectables = (selectables, onSelect) => {
    selectables->Js.Array2.mapi((selectable, index) =>
      <button
        key={string_of_int(index)}
        onClick={_ => onSelect(selectable)}
        className="w-full text-left cursor-pointer block p-3 text-xs font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-primary-50 focus:outline-none focus:text-primary-500 focus:bg-primary-50">
        {Selectable.name(selectable)->React.string}
      </button>
    )
  }

  let showSelected = (placeholder, selected, loading, disabled) => {
    <button
      disabled={loading || disabled}
      className="flex items-center justify-between appearance-none w-full bg-white border border-gray-200 rounded py-3 px-4 mt-2 leading-tight hover:border-gray-500 focus:outline-none focus:ring-2 focus:ring-focusColor-500"
      key="selected">
      <span>
        {switch selected {
        | Some(s) => Selectable.name(s)
        | None => placeholder
        }->React.string}
      </span>
      {loading
        ? <FaIcon classes="fas fa-spinner fa-spin" />
        : <FaIcon classes="fas fa-caret-down ml-2" />}
    </button>
  }
  @react.component
  let make = (
    ~placeholder,
    ~selectables,
    ~selected,
    ~onSelect,
    ~loading=false,
    ~disabled=false,
  ) => {
    <Dropdown2
      selected={showSelected(placeholder, selected, loading, disabled)}
      contents={showSelectables(selectables, onSelect)}
    />
  }
}
