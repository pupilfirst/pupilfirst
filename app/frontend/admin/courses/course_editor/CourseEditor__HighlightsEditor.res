open CourseEditor__Types

let t = I18n.t(~scope="components.CourseEditor__HighlightsEditor")
let ts = I18n.ts

let str = React.string

let icons = [
  "book-open-solid",
  "book-open-light",
  "lamp-solid",
  "badge-check-solid",
  "writing-pad-solid",
  "eye-solid",
  "users-solid",
  "certificate-regular",
  "briefcase-solid",
  "globe-light",
  "signal-fill-solid",
  "signal-2-light",
  "signal-1-light",
  "academic-cap-solid",
  "award-solid",
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

let selected = (highlight: Course.Highlight.t) => {
  <button
    title={t("selected_button.title")}
    ariaLabel={t("selected_button.title")}
    className="flex items-center justify-center cursor-pointer bg-white border border-gray-300 text-gray-900 rounded-lg p-3 w-12 h-12 me-1 hover:bg-primary-100 hover:text-primary-400 hover:border-primary-400 focus:outline-none focus:bg-primary-100 focus:text-primary-400 focus:border-primary-400">
    <PfIcon className={"text-lg if i-" ++ highlight.icon} />
  </button>
}

let contents = (replaceCB, highlight) => {
  Js.Array.map(
    icon =>
      <button
        key=icon
        title={t("select") ++ " " ++ icon}
        ariaLabel={t("select") ++ " " ++ icon}
        className="flex items-center justify-center p-3 w-full h-full text-gray-900 hover:text-primary-500 focus:outline-none focus:text-primary-500 focus:bg-gray-50"
        onClick={_ => updateIcon(replaceCB, highlight, icon)}>
        <PfIcon className={"text-lg if i-" ++ icon} />
      </button>,
    icons,
  )
}

@react.component
let make = (~highlights, ~updateHighlightsCB) => {
  <div> {Js.Array.mapi((highlight, index) => {
      let replaceCB = replace(index, highlights, updateHighlightsCB)
      <Spread props={"data-highlight-index": index} key={string_of_int(index)}>
        <div key={string_of_int(index)} className="flex items-start py-2 relative">
          <div className="flex items-start w-full bg-gray-50 border rounded-lg p-4 me-1">
            <Dropdown2
              selected={selected(highlight)}
              contents={contents(replaceCB, highlight)}
              childClasses="grid grid-cols-5"
              width="w-64"
            />
            <div className="w-full">
              <input
                className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 leading-tight font-semibold focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                id={"highlight-" ++ string_of_int(index) ++ "-title"}
                type_="text"
                placeholder={t("title.placeholder")}
                ariaLabel={t("title.placeholder")}
                maxLength=150
                value={highlight.title}
                onChange={event =>
                  updateTitle(replaceCB, highlight, ReactEvent.Form.target(event)["value"])}
              />
              <input
                className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-1 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
                id={"highlight-" ++ string_of_int(index) ++ "-description"}
                type_="text"
                placeholder={t("description.placeholder")}
                ariaLabel={t("description.placeholder")}
                maxLength=250
                value={highlight.description}
                onChange={event =>
                  updateDescription(replaceCB, highlight, ReactEvent.Form.target(event)["value"])}
              />
            </div>
          </div>
          <div
            className="shrink-0 bg-gray-50 border rounded flex flex-col text-xs sticky top-0">
            {ReactUtils.nullIf(
              <button
                title={t("move_up")}
                ariaLabel={t("move_up")}
                onClick={_ => moveUp(index, highlights, updateHighlightsCB)}
                className="px-2 py-1 focus:outline-none text-sm text-gray-600 hover:bg-gray-300 hover:text-gray-900 focus:bg-gray-300 focus:text-gray-900 overflow-hidden cursor-pointer">
                <FaIcon classes={"fas fa-arrow-up"} />
              </button>,
              index == 0,
            )}
            {ReactUtils.nullIf(
              <button
                title={t("move_down")}
                ariaLabel={t("move_down")}
                onClick={_ => moveDown(index, highlights, updateHighlightsCB)}
                className="px-2 py-1 focus:outline-none text-sm text-gray-600 hover:bg-gray-300 hover:text-gray-900 focus:bg-gray-300 focus:text-gray-900 overflow-hidden cursor-pointer">
                <FaIcon classes={"fas fa-arrow-down"} />
              </button>,
              index == Js.Array.length(highlights) - 1,
            )}
            <button
              onClick={_ => removeHighlight(index, highlights, updateHighlightsCB)}
              title={t("delete_highlight")}
              ariaLabel={t("delete_highlight")}
              className="px-2 py-1 focus:outline-none text-sm text-gray-600 hover:bg-gray-300 hover:text-red-500 focus:bg-gray-300 focus:text-red-500 overflow-hidden cursor-pointer">
              <FaIcon classes={"fas fa-trash-alt"} />
            </button>
          </div>
        </div>
      </Spread>
    }, highlights)->React.array} <div>
      {ReactUtils.nullIf(
        <button
          className="w-full mt-2 btn border border-dashed text-sm border-primary-500 bg-gray-50"
          onClick={_ => addHighlight(highlights, updateHighlightsCB)}>
          {t("add_highlight")->str}
        </button>,
        Js.Array.length(highlights) >= 4,
      )}
    </div> </div>
}
