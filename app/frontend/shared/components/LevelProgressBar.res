%%raw(`import "./LevelProgressBar.css"`)

let str = React.string
let t = I18n.t(~scope="components.LevelProgressBar")

let levelClasses = (levelNumber, levelCompleted, currentLevelNumber) => {
  let reached =
    levelNumber <= currentLevelNumber ? "level-progress-bar__student-level--reached" : ""

  let current =
    levelNumber == currentLevelNumber ? " level-progress-bar__student-level--current" : ""

  let completed = levelCompleted ? " level-progress-bar__student-level--completed" : ""

  reached ++ (current ++ completed)
}

@react.component
let make = (~levels, ~currentLevelNumber, ~courseCompleted, ~className="") => {
  <div className>
    <div className="flex justify-between items-end">
      <h6 className="text-sm font-semibold"> {t("heading") |> str} </h6>
      {courseCompleted
        ? <p className="text-green-600 font-semibold">
            {`🎉` |> str} <span className="text-xs ms-px"> {t("course_completed") |> str} </span>
          </p>
        : React.null}
    </div>
    <div className="h-12 flex items-center">
      <ul
        className={"level-progress-bar__student-progress flex w-full " ++ (
          courseCompleted ? "level-progress-bar__student-progress--completed" : ""
        )}>
        {levels->Js.Array2.mapi((levelCompleted, index) => {
          let levelNumber = index + 1

          <li
            key={Belt.Int.toString(levelNumber)}
            className={"flex-1 level-progress-bar__student-level " ++
            levelClasses(levelNumber, levelCompleted, currentLevelNumber)}>
            <span className="level-progress-bar__student-level-count">
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
    "className": optional(field("className", string), json),
  })
}
