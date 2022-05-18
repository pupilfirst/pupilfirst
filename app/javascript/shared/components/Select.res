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
        className="w-full text-left cursor-pointer block p-3 text-xs font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-gray-200">
        {Selectable.name(selectable)->React.string}
      </button>
    )
  }

  let showSelected = (placeholder, selected, loading, disabled) => {
    <button
      disabled={loading || disabled}
      className="flex items-center justify-between appearance-none w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
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
