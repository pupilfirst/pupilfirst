%%raw(`import "./CoursesStudents__StudentDistribution.css"`)

open CoursesStudents__Types
let str = React.string
let tr = I18n.t(~scope="components.CoursesStudents__StudentDistribution")
let ts = I18n.t(~scope="shared")

let stylingForLevelPills = percentageStudents => {
  let emptyStyle = ReactDOM.Style.make()
  let styleWithWidth = ReactDOM.Style.make(~width=percentageStudents->Js.Float.toString ++ "%", ())

  if 0.0 == percentageStudents {
    ("w-8 flex-grow", emptyStyle, "bg-green-200 text-green-800")
  } else if 0.0 <= percentageStudents && percentageStudents < 5.0 {
    ("w-8 flex-shrink-0", emptyStyle, "bg-green-200 text-green-800")
  } else if 5.0 <= percentageStudents && percentageStudents < 20.0 {
    ("", styleWithWidth, "bg-green-300 text-green-800")
  } else if 20.0 <= percentageStudents && percentageStudents < 40.0 {
    ("", styleWithWidth, "bg-green-400 text-green-900")
  } else if 40.0 <= percentageStudents && percentageStudents < 60.0 {
    ("", styleWithWidth, "bg-green-500 text-white")
  } else if 60.0 <= percentageStudents && percentageStudents < 80.0 {
    ("", styleWithWidth, "bg-green-600 text-white")
  } else {
    ("", styleWithWidth, "bg-green-700 text-white")
  }
}

let onLevelSelect = (value, params, href) => {
  switch params {
  | Some(p) =>
    p->Webapi.Url.URLSearchParams.set("level", value)
    RescriptReactRouter.push("?" ++ Webapi.Url.URLSearchParams.toString(p))
  | None =>
    let search = Webapi.Dom.location->Webapi.Dom.Location.search
    let params = Webapi.Url.URLSearchParams.make(search)
    params->Webapi.Url.URLSearchParams.set("level", value)
    let currentPath = Webapi.Dom.location->Webapi.Dom.Location.pathname
    let searchString = Webapi.Url.URLSearchParams.toString(params)
    let path = Belt.Option.getWithDefault(href, currentPath)
    Webapi.Dom.window->Webapi.Dom.Window.setLocation(`${path}?${searchString}`)
  }
}

let studentDistributionSkeleton =
  <div className="skeleton-body-container w-full mx-auto">
    <div className="skeleton-body-wrapper px-3 lg:px-0">
      <div className="flex">
        <div className="w-1/6">
          <div className="skeleton-placeholder__line-sm skeleton-animate w-6 mx-auto" />
          <div className="skeleton-placeholder__line-md skeleton-animate mt-2" />
        </div>
        <div className="w-5/12">
          <div className="skeleton-placeholder__line-sm skeleton-animate w-6 mx-auto" />
          <div className="skeleton-placeholder__line-md skeleton-animate mt-2" />
        </div>
        <div className="w-1/4">
          <div className="skeleton-placeholder__line-sm skeleton-animate w-6 mx-auto" />
          <div className="skeleton-placeholder__line-md skeleton-animate mt-2" />
        </div>
        <div className="w-1/12">
          <div className="skeleton-placeholder__line-sm skeleton-animate w-6 mx-auto" />
          <div className="skeleton-placeholder__line-md skeleton-animate mt-2" />
        </div>
        <div className="w-1/12">
          <div className="skeleton-placeholder__line-sm skeleton-animate w-6 mx-auto" />
          <div className="skeleton-placeholder__line-md skeleton-animate mt-2" />
        </div>
      </div>
    </div>
  </div>

@react.component
let make = (~studentDistribution, ~params=?, ~href=?) => {
  <div ariaLabel="Students level-wise distribution" className="w-full py-4">
    {
      let totalStudentsInCourse =
        studentDistribution->Js.Array2.reduce(
          (x, y) => x + DistributionInLevel.studentsInLevel(y),
          0,
        )

      let completedLevels = DistributionInLevel.levelsCompletedByAllStudents(studentDistribution)

      <div className="flex w-full border bg-gray-50 rounded font-semibold ">
        {studentDistribution
        ->Js.Array2.filter(level => DistributionInLevel.number(level) != 0)
        ->DistributionInLevel.sort
        ->Js.Array2.map(level => {
          let percentageStudents = DistributionInLevel.percentageStudents(
            level,
            totalStudentsInCourse,
          )
          let (pillClass, style, pillColor) = stylingForLevelPills(percentageStudents)
          let tip =
            <div className="">
              <p> {LevelLabel.format(DistributionInLevel.number(level)->string_of_int)->str} </p>
              <p>
                {(ts("students") ++
                ": " ++
                DistributionInLevel.studentsInLevel(level)->string_of_int)->str}
              </p>
              <p>
                {(ts("percentage") ++
                ": " ++
                percentageStudents->Js.Float.toFixedWithPrecision(~digits=1))->str}
              </p>
            </div>
          <div
            key={DistributionInLevel.id(level)}
            ariaLabel={"Students in level " ++ DistributionInLevel.number(level)->string_of_int}
            className={"student-distribution__container text-center relative focus-within:outline-none focus-within:opacity-75 " ++
            pillClass}
            style>
            <label
              htmlFor={tr("students_level") ++ DistributionInLevel.number(level)->string_of_int}
              className="absolute -mt-5 start-0 end-0 inline-block text-xs text-gray-600 text-center">
              {level->DistributionInLevel.shortName->str}
            </label>
            <Tooltip className="w-full" tip position=#Bottom>
              <button
                id={tr("students_level") ++ DistributionInLevel.number(level)->string_of_int}
                onClick={_ => onLevelSelect(DistributionInLevel.filterName(level), params, href)}
                className={"student-distribution__pill w-full hover:shadow-inner focus:shadow-inner relative cursor-pointer border-white text-xs leading-none text-center " ++ (
                  completedLevels->Js.Array2.includes(level)
                    ? "bg-yellow-300 text-yellow-900"
                    : switch DistributionInLevel.unlocked(level) {
                      | true => pillColor
                      | false =>
                        "student-distribution__pill--locked cursor-default bg-gray-300" ++ " text-gray-800"
                      }
                )}>
                {completedLevels->Js.Array2.includes(level)
                  ? <PfIcon className="if i-check-solid text-tiny" />
                  : <div>
                      <div
                        className={level->DistributionInLevel.unlocked
                          ? ""
                          : "student-distribution__team-count-value"}>
                        {level->DistributionInLevel.studentsInLevel->string_of_int->str}
                      </div>
                      {level->DistributionInLevel.unlocked
                        ? React.null
                        : <div className="student-distribution__locked-icon">
                            <i className="fas fa-lock text-tiny" />
                          </div>}
                    </div>}
              </button>
            </Tooltip>
          </div>
        })
        ->React.array}
      </div>
    }
  </div>
}

let makeFromJson = props => {
  open Json.Decode

  let studentDistribution = field("studentDistribution", array(DistributionInLevel.decode), props)
  let href = optional(field("href", string), props)

  make({
    "studentDistribution": studentDistribution,
    "params": None,
    "href": href,
  })
}
