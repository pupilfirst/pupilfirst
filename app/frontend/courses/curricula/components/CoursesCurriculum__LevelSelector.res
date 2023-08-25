open CoursesCurriculum__Types

let str = React.string

let levelZeroSelectorClasses = isSelected => {
  let defaultClasses = "w-1/2 px-4 py-2 focus:outline-none text-sm font-semibold flex items-center justify-center "
  defaultClasses ++ (
    isSelected ? "bg-primary-100 text-primary-500 hover:bg-primary-100 hover:text-primary-500" : ""
  )
}

let levelName = level =>
  LevelLabel.format(~short=true, ~name=level |> Level.name, level |> Level.number |> string_of_int)

let selectableLevels = (orderedLevels, setSelectedLevelId, preview) => {
  orderedLevels |> Js.Array.map(level => {
    let icon = if preview {
      "fas fa-eye"
    } else if level |> Level.isUnlocked {
      "inline-block"
    } else {
      "fas fa-lock text-gray-600"
    }

    <button
      className="flex focus:outline-none p-2 w-full whitespace-normal"
      key={level |> Level.id}
      onClick={_ => setSelectedLevelId(level |> Level.id)}>
      <span className="me-2 mt-px"> <FaIcon classes={"fa-fw " ++ icon} /> </span>
      {levelName(level) |> str}
    </button>
  })
}

let untabbedLevelSelector = (selectedLevel, orderedLevels, setSelectedLevelId, preview) => {
  let selected =
    <button className="font-semibold w-full px-2 h-10 flex items-center justify-between">
      <span className="grow truncate w-0"> {selectedLevel |> levelName |> str} </span>
      <FaIcon classes="fas fa-caret-down ms-1" />
    </button>

  <Dropdown
    selected
    contents={selectableLevels(orderedLevels, setSelectedLevelId, preview)}
    className="grow cursor-pointer rounded-lg bg-primary-100 hover:bg-gray-50 hover:text-primary-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-inset focus-witin:ring-focusColor-500 focus:text-primary-500 focus:bg-gray-50"
  />
}

let tabbedLevelSelector = (
  orderedLevels,
  selectedLevel,
  setSelectedLevelId,
  showLevelZero,
  setShowLevelZero,
  levelZero,
  preview,
) => {
  let selected = hideCaret =>
    <button
      className="rounded-s-lg font-semibold w-full px-2 h-10 flex items-center justify-between">
      <span className="grow text-center truncate w-0"> {selectedLevel |> levelName |> str} </span>
      <FaIcon classes={"fas fa-caret-down ms-1" ++ (hideCaret ? " invisible" : "")} />
    </button>

  let numberedLevelSelector = showLevelZero
    ? <div
        className="cursor-pointer text-sm grow rounded-s-lg hover:bg-gray-50 hover:text-primary-500"
        onClick={_ => setShowLevelZero(false)}>
        {selected(true)}
      </div>
    : <Dropdown
        key="numbered-level-selector"
        selected={selected(false)}
        contents={selectableLevels(orderedLevels, setSelectedLevelId, preview)}
        className="cursor-pointer grow rounded-s-lg bg-primary-100 hover:bg-gray-50 hover:text-primary-500"
      />

  [
    numberedLevelSelector,
    <button
      key="level-zero-selector"
      className={"border-s rounded-e-lg bg-white border-gray-300 font-semibold truncate hover:bg-gray-50 hover:text-primary-500 " ++
      levelZeroSelectorClasses(showLevelZero)}
      onClick={_e => setShowLevelZero(true)}>
      {levelZero |> Level.name |> str}
    </button>,
  ] |> React.array
}

@react.component
let make = (
  ~levels,
  ~selectedLevel,
  ~preview,
  ~setSelectedLevelId,
  ~showLevelZero,
  ~setShowLevelZero,
  ~levelZero,
) => {
  let orderedLevels = levels |> Js.Array.filter(l => l |> Level.number != 0) |> Level.sort

  <div className="bg-gray-50 px-3 py-2 mt-3 md:px-0 sticky top-0 z-10">
    <div
      className="flex justify-center max-w-sm md:max-w-xl mx-auto rounded-lg border border-gray-300 h-11">
      {switch levelZero {
      | Some(levelZero) =>
        tabbedLevelSelector(
          orderedLevels,
          selectedLevel,
          setSelectedLevelId,
          showLevelZero,
          setShowLevelZero,
          levelZero,
          preview,
        )
      | None => untabbedLevelSelector(selectedLevel, orderedLevels, setSelectedLevelId, preview)
      }}
    </div>
  </div>
}
