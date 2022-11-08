let str = React.string
let t = I18n.t(~scope="components.LevelProgressBar")

let levelClasses = (levelNumber, levelCompleted, currentLevelNumber) => {
  let reached = levelNumber <= currentLevelNumber ? "student-overlay__student-level--reached" : ""

  let current = levelNumber == currentLevelNumber ? " student-overlay__student-level--current" : ""

  let completed = levelCompleted ? " student-overlay__student-level--completed" : ""

  reached ++ (current ++ completed)
}

@react.component
let make = (~levels, ~currentLevelNumber, ~courseCompleted) => {
  <div className="mb-8">
    <div className="flex justify-between items-end">
      <h6 className="text-sm font-semibold"> {t("heading") |> str} </h6>
    </div>
    <div className="h-12 flex items-center">
      <ul
        className={"student-overlay__student-level-progress flex w-full " ++ (
          courseCompleted ? "student-overlay__student-level-progress--completed" : ""
        )}>
        {levels->Js.Array2.mapi((levelCompleted, index) => {
          let levelNumber = index + 1

          <li
            key={Belt.Int.toString(levelNumber)}
            className={"flex-1 student-overlay__student-level " ++
            levelClasses(levelNumber, levelCompleted, currentLevelNumber)}>
            <span className="student-overlay__student-level-count">
              {levelNumber |> string_of_int |> str}
            </span>
          </li>
        }) |> React.array}
      </ul>
    </div>
  </div>
}

let makeFromJson = json => {
  open Json.Decode

  make({
    "levels": field("levels", array(bool), json),
    "currentLevelNumber": field("currentLevelNumber", int, json),
    "courseCompleted": field("courseCompleted", bool, json),
  })
}
