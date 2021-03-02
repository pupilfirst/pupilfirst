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

let selected = highlight => {
  <div className="bg-white border border-gray-400 rounded py-3 px-4 h-12 mr-1">
    <PfIcon className={"text-primary-500 if i-" ++ Course.Highlight.icon(highlight)} />
  </div>
}

let contents = (replaceCB, highlight) => {
  Js.Array.map(
    icon =>
      <span key=icon className="p-4" onClick={_ => updateIcon(replaceCB, highlight, icon)}>
        <PfIcon className={"w-12 text-primary-500 if i-" ++ icon} />
      </span>,
    icons,
  )
}

@react.component
let make = (~highlights, ~updateHighlightsCB) => {
  <div> {Js.Array.mapi((highlight, index) => {
      let replaceCB = replace(index, highlights, updateHighlightsCB)
      <div key={string_of_int(index)} className="p-4 flex bg-gray-200 rounded-lg mt-4">
        <Dropdown2
          selected={selected(highlight)}
          contents={contents(replaceCB, highlight)}
          childClasses="flex w-40 flex-wrap"
          width="w-40"
        />
        <div className="w-full">
          <input
            className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
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
        <button
          onClick={_ => removeHighlight(index, highlights, updateHighlightsCB)}
          className="bg-white border border-gray-400 rounded py-3 px-4 h-12 mr-1 cursor-pointer">
          <FaIcon classes={"fas fa-trash-alt"} />
        </button>
      </div>
    }, highlights)->React.array} <div>
      <button
        className="btn btn-primary btn-large"
        onClick={_ => addHighlight(highlights, updateHighlightsCB)}>
        {"Add Course Highlight"->str}
      </button>
    </div> </div>
}
