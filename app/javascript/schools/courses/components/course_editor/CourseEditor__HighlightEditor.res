open CourseEditor__Types

let t = I18n.t(~scope="components.CourseEditor__Form")

let str = ReasonReact.string

let icons = [
  "plus-circle-solid",
  "plus-circle-regular",
  "plus-circle-light",
  "lamp-solid",
  "check-light",
  "times-light",
  "badge-check-solid",
  "badge-check-regular",
  "badge-check-light",
  "writing-pad-solid",
  "eye-solid",
  "users-solid",
  "users-regular",
  "users-light",
  "ellipsis-h-solid",
  "ellipsis-h-regular",
  "ellipsis-h-light",
  "check-square-alt-solid",
  "check-square-alt-regular",
  "check-square-alt-light",
]

let replace = (index, highlights, updateHighlightsCB, newHighlight) => {
  updateHighlightsCB(ArrayUtils.replaceWithIndex(index, newHighlight, highlights))
}

let updateTitle = (replaceCB, highlight, title) => {
  replaceCB(Course.Highlight.updateTitle(highlight, title))
}

let updateDescription = (replaceCB, highlight, description) => {
  replaceCB(Course.Highlight.updateDescription(highlight, description))
}

let updateIcon = (replaceCB, highlight, icon) => {
  replaceCB(Course.Highlight.updateIcon(highlight, icon))
}

let addHighlight = (highlights, updateHighlightsCB) => {
  updateHighlightsCB(Js.Array.concat([Course.Highlight.empty()], highlights))
}

let removeHighlight = (index, highlights, updateHighlightsCB) => {
  updateHighlightsCB(Js.Array.filteri((_a, i) => i != index, highlights))
}

let moveUp = (index, highlights, updateHighlightsCB) => {
  updateHighlightsCB(ArrayUtils.swapUp(index, highlights))
}

let moveDown = (index, highlights, updateHighlightsCB) => {
  updateHighlightsCB(ArrayUtils.swapDown(index, highlights))
}

let selected = highlight => {
  <button
    className="flex items-center justify-center cursor-pointer bg-white border border-gray-400 text-gray-900 rounded-lg p-3 w-12 h-12 mr-1 hover:bg-primary-100 hover:text-primary-400 hover:border-primary-400">
    <PfIcon className={"text-lg if i-" ++ Course.Highlight.icon(highlight)} />
  </button>
}

let contents = (replaceCB, highlight) => {
  Js.Array.map(
    icon =>
      <button
        key=icon
        className="flex items-center justify-center p-3 w-full h-full"
        onClick={_ => updateIcon(replaceCB, highlight, icon)}>
        <PfIcon className={" text-gray-900 text-lg if i-" ++ icon} />
      </button>,
    icons,
  )
}

@react.component
let make = (~highlights, ~updateHighlightsCB) => {
  <div> {Js.Array.mapi((highlight, index) => {
      let replaceCB = replace(index, highlights, updateHighlightsCB)
      <div key={string_of_int(index)} className="flex items-start py-2 relative">
        <div className="flex items-start w-full bg-gray-100 border rounded-lg p-4 mr-1">
          <Dropdown2
            selected={selected(highlight)}
            contents={contents(replaceCB, highlight)}
            childClasses="grid grid-cols-5"
            width="w-64"
          />
          <div className="w-full">
            <input
              className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-tight font-semibold focus:outline-none focus:bg-white focus:border-gray-500"
              id={string_of_int(index) ++ "-title"}
              type_="text"
              placeholder="Enter title"
              maxLength=50
              value={Course.Highlight.title(highlight)}
              onChange={event =>
                updateTitle(replaceCB, highlight, ReactEvent.Form.target(event)["value"])}
            />
            <input
              className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-1 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
              id={string_of_int(index) ++ "-description"}
              type_="text"
              placeholder="Enter description"
              maxLength=150
              value={Course.Highlight.description(highlight)}
              onChange={event =>
                updateDescription(replaceCB, highlight, ReactEvent.Form.target(event)["value"])}
            />
          </div>
        </div>
        <div
          className="flex-shrink-0 bg-gray-100 border rounded flex flex-col text-xs sticky top-0">
          {ReactUtils.nullIf(
            <button
              onClick={_ => moveUp(index, highlights, updateHighlightsCB)}
              className="px-2 py-1 focus:outline-none text-sm text-gray-700 hover:bg-gray-300 hover:text-gray-900 overflow-hidden cursor-pointer">
              <FaIcon classes={"fas fa-arrow-up"} />
            </button>,
            index == 0,
          )}
          {ReactUtils.nullIf(
            <button
              onClick={_ => moveDown(index, highlights, updateHighlightsCB)}
              className="px-2 py-1 focus:outline-none text-sm text-gray-700 hover:bg-gray-300 hover:text-gray-900 overflow-hidden cursor-pointer">
              <FaIcon classes={"fas fa-arrow-down"} />
            </button>,
            index == Js.Array.length(highlights) - 1,
          )}
          <button
            onClick={_ => removeHighlight(index, highlights, updateHighlightsCB)}
            className="px-2 py-1 focus:outline-none text-sm text-gray-700 hover:bg-gray-300 hover:text-gray-900 overflow-hidden cursor-pointer">
            <FaIcon classes={"fas fa-trash-alt"} />
          </button>
        </div>
      </div>
    }, highlights)->React.array} <div>
      {ReactUtils.nullIf(
        <button
          className="w-full mt-2 btn border border-dashed text-sm border-primary-500 bg-gray-200"
          onClick={_ => addHighlight(highlights, updateHighlightsCB)}>
          {"Add Course Highlight"->str}
        </button>,
        Js.Array.length(highlights) >= 4,
      )}
    </div> </div>
}
