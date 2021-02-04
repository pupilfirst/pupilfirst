%bs.raw(`require("./CoursesStudents__StudentDistribution.css")`)

open CoursesStudents__Types
let str = React.string

module StudentDistributionQuery = %graphql(
  `
    query StudentDistribution($courseId: ID!, $coachNotes: CoachNoteFilter!, $coachId: ID, $tags: [String!]!) {
      studentDistribution(courseId: $courseId, coachNotes: $coachNotes, coachId: $coachId, tags: $tags) {
        id
        number
        studentsInLevel
        teamsInLevel
        unlocked
      }
    }
  `
)

let stylingForLevelPills = percentageStudents => {
  let emptyStyle = ReactDOMRe.Style.make()
  let styleWithWidth = ReactDOMRe.Style.make(
    ~width=(percentageStudents |> Js.Float.toString) ++ "%",
    (),
  )
  if 0.0 <= percentageStudents && percentageStudents < 5.0 {
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

let refreshStudentDistribution = (
  courseId,
  filterCoach,
  filterCoachNotes,
  filterTags,
  setStudentDistribution,
) => {
  let coachId = filterCoach->Belt.Option.map(coach => Coach.id(coach))
  let tags = filterTags->Belt.Set.String.toArray

  StudentDistributionQuery.make(~courseId, ~coachNotes=filterCoachNotes, ~tags, ~coachId?, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    let distribution =
      response["studentDistribution"] |> Array.map(DistributionInLevel.fromJsObject)

    setStudentDistribution(_ => Some(distribution))
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    setStudentDistribution(_ => Some([]))
    Js.Promise.resolve()
  })
  |> ignore
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
let make = (~selectLevelCB, ~courseId, ~filterCoach, ~filterCoachNotes, ~filterTags, ~reloadAt) => {
  let (studentDistribution, setStudentDistribution) = React.useState(() => None)

  React.useEffect4(() => {
    switch reloadAt {
    | None => ()
    | Some(_) =>
      refreshStudentDistribution(
        courseId,
        filterCoach,
        filterCoachNotes,
        filterTags,
        setStudentDistribution,
      )
    }

    None
  }, (filterCoach, filterCoachNotes, filterTags, reloadAt))

  <div
    ariaLabel="Students level-wise distribution"
    className="w-full pt-8 max-w-3xl mx-auto hidden md:block">
    {switch studentDistribution {
    | None => studentDistributionSkeleton
    | Some(distribution) =>
      let totalStudentsInCourse =
        distribution |> Array.fold_left((x, y) => x + DistributionInLevel.studentsInLevel(y), 0)
      let completedLevels = DistributionInLevel.levelsCompletedByAllStudents(distribution)
      totalStudentsInCourse > 0
        ? <div className="flex w-full border bg-gray-100 rounded font-semibold ">
            {distribution
            |> Js.Array.filter(level => DistributionInLevel.number(level) != 0)
            |> DistributionInLevel.sort
            |> Array.map(level => {
              let percentageStudents = DistributionInLevel.percentageStudents(
                level,
                totalStudentsInCourse,
              )
              let (pillClass, style, pillColor) = stylingForLevelPills(percentageStudents)
              let tip =
                <div className="text-left">
                  <p> {LevelLabel.format(DistributionInLevel.number(level) |> string_of_int) |> str} </p>
                  <p>
                    {"Students: " ++ string_of_int(DistributionInLevel.studentsInLevel(level))
                      |> str}
                  </p>
                  {DistributionInLevel.studentsInLevel(level) !=
                    DistributionInLevel.teamsInLevel(level)
                    ? <p>
                        {"Teams: " ++ string_of_int(DistributionInLevel.teamsInLevel(level)) |> str}
                      </p>
                    : React.null}
                  <p>
                    {"Percentage: " ++ Js.Float.toFixedWithPrecision(percentageStudents, ~digits=1)
                      |> str}
                  </p>
                </div>
              <div
                key={DistributionInLevel.id(level)}
                ariaLabel={"Students in level " ++
                (DistributionInLevel.number(level) |> string_of_int)}
                className={"student-distribution__container text-center relative " ++ pillClass}
                style>
                <label
                  className="absolute -mt-5 left-0 right-0 inline-block text-xs text-gray-700 text-center">
                  {level |> DistributionInLevel.shortName |> str}
                </label>
                <Tooltip className="w-full" tip position=#Bottom>
                  <div
                    onClick={_ => DistributionInLevel.id(level)->selectLevelCB}
                    className={"student-distribution__pill hover:shadow-inner focus:shadow-inner relative cursor-pointer border-white text-xs leading-none text-center " ++ (
                      completedLevels |> Array.mem(level)
                        ? "bg-yellow-300 text-yellow-900"
                        : switch DistributionInLevel.unlocked(level) {
                          | true => pillColor
                          | false =>
                            "student-distribution__pill--locked cursor-default bg-gray-300" ++ " text-gray-800"
                          }
                    )}>
                    {completedLevels |> Array.mem(level)
                      ? <PfIcon className="if i-check-solid text-tiny" />
                      : <div>
                          <div
                            className={level |> DistributionInLevel.unlocked
                              ? ""
                              : "student-distribution__team-count-value"}>
                            {level |> DistributionInLevel.teamsInLevel |> string_of_int |> str}
                          </div>
                          {level |> DistributionInLevel.unlocked
                            ? React.null
                            : <div className="student-distribution__locked-icon">
                                <i className="fas fa-lock text-tiny" />
                              </div>}
                        </div>}
                  </div>
                </Tooltip>
              </div>
            })
            |> React.array}
          </div>
        : React.null
    }}
  </div>
}
