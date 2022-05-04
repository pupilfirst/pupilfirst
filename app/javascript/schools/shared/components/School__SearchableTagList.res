let str = React.string

type state = string

let handleClick = (tag, send, clickCB) => {
  clickCB(tag)
  send("")
}

let search = (state, send, allowNewTags, selectedTags, unselectedTags, addTagCB) => {
  // Remove all excess space characters from the user input.
  let normalizedString = Js.String.replaceByRe(
    Js.Re.fromStringWithFlags("\\s+", ~flags="g"),
    " ",
    Js.String.trim(state),
  )

  switch normalizedString {
  | "" => []
  | searchString =>
    let allTags = Js.Array.map(
      String.lowercase_ascii,
      Js.Array.concat(selectedTags, unselectedTags),
    )
    /* If addition of tag is allowed, and it IS new, then display that option at the front. */
    let initial = if allowNewTags && !Array.mem(searchString->String.lowercase_ascii, allTags) {
      [
        <button
          title={"Add new tag " ++ searchString}
          ariaLabel={"Add new tag " ++ searchString}
          key=searchString
          onClick={_e => handleClick(searchString, send, addTagCB)}
          className="inline-flex cursor-pointer items-center bg-primary-100 border border-dashed border-primary-500 text-primary-700 hover:shadow-md hover:text-primary-800 focus:outline-none focus:shadow-md focus:text-primary-800 rounded-lg px-2 py-px mt-1 mr-2 text-xs overflow-hidden">
          {searchString->str} <i className="fas fa-plus ml-1 text-sm text-primary-600" />
        </button>,
      ]
    } else {
      []
    }

    let searchResults =
      unselectedTags
      |> Js.Array.filter(tag =>
        tag |> String.lowercase_ascii |> Js.String.includes(searchString |> String.lowercase_ascii)
      )
      |> ArrayUtils.copyAndSort(String.compare)
      |> Js.Array.map(tag =>
        <span
          title={"Pick tag " ++ tag}
          key=tag
          className="inline-flex cursor-pointer items-center bg-gray-200 border border-gray-500 text-gray-900 hover:shadow hover:border-primary-500 hover:bg-primary-100 hover:text-primary-600 rounded-lg px-2 py-px mt-1 mr-1 text-xs overflow-hidden"
          onMouseDown={_e => handleClick(tag, send, addTagCB)}>
          {tag->str}
        </span>
      )
    initial->Array.append(searchResults)
  }
}

let reducer = (_state, searchString) => searchString

@react.component
let make = (~unselectedTags, ~selectedTags, ~addTagCB, ~removeTagCB, ~allowNewTags) => {
  let (state, send) = React.useReducer(reducer, "")
  let results = search(state, send, allowNewTags, selectedTags, unselectedTags, addTagCB)
  <div className="mt-2">
    {ReactUtils.nullUnless(
      <div className="flex flex-wrap">
        {Js.Array.map(
          tag =>
            <div
              key=tag
              className="flex items-center bg-gray-200 border border-gray-500 rounded-lg mt-1 mr-1 text-xs text-gray-900 overflow-hidden">
              <span className="px-2 py-px"> {tag |> str} </span>
              <button
                ariaLabel={"Remove tag " ++ tag}
                title={"Remove tag " ++ tag}
                className="flex items-center px-2 h-full cursor-pointer text-gray-700 hover:text-red-500 hover:bg-gray-300 focus:outline-none focus:text-red-500 focus:bg-gray-300 border-l border-gray-400"
                onClick={_e => handleClick(tag, send, removeTagCB)}>
                <i className="fas fa-times" />
              </button>
            </div>,
          ArrayUtils.copyAndSort(String.compare, selectedTags),
        )->React.array}
      </div>,
      ArrayUtils.isNotEmpty(selectedTags),
    )}
    <input
      value=state
      onChange={event => send(ReactEvent.Form.target(event)["value"])}
      className="appearance-none block bg-white leading-snug border border-gray-400 rounded w-full py-3 px-4 mt-2 focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-indigo-500"
      id="tags"
      type_="text"
      placeholder={allowNewTags ? "Search for, or add new tags" : "Select tags"}
    />
    {ReactUtils.nullUnless(
      <div
        className="flex flex-wrap border border-gray-400 bg-white mt-1 rounded-lg shadow-lg searchable-tag-list__dropdown relative px-4 pt-2 pb-3">
        {results->React.array}
      </div>,
      ArrayUtils.isNotEmpty(results),
    )}
  </div>
}
