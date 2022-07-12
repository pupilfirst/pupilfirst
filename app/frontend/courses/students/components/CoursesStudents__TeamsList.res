%%raw(`import "./CoursesStudents__Root.css"`)
let t = I18n.t(~scope="components.CoursesStudents__TeamsList")

open CoursesStudents__Types

let str = React.string

let tr = I18n.t(~scope="components.CoursesStudents__TeamsList")
let ts = I18n.t(~scope="shared")

let levelInfo = (levelId, levels) =>
  <span
    className="inline-flex flex-col items-center rounded bg-orange-100 border border-orange-300 px-2 pt-2 pb-1">
    <p className="text-xs font-semibold"> {ts("level") |> str} </p>
    <p className="font-bold">
      {levels
      |> ArrayUtils.unsafeFind(
        (l: Level.t) => l.id == levelId,
        "Unable to find level with id: " ++ (levelId ++ "in CoursesStudents__TeamsList"),
      )
      |> Level.number
      |> string_of_int
      |> str}
    </p>
  </span>

let studentTags = student => {
  student |> TeamInfo.studentTags |> ArrayUtils.isNotEmpty
    ? <div className="hidden md:flex flex-wrap">
        {student
        |> TeamInfo.studentTags
        |> Js.Array.map(tag =>
          <div
            className="bg-blue-100 rounded mt-1 mr-1 py-px px-2 text-tiny text-gray-900" key={tag}>
            {str(tag)}
          </div>
        )
        |> React.array}
      </div>
    : React.null
}

let teamTags = team => {
  team |> TeamInfo.tags |> ArrayUtils.isNotEmpty
    ? <div className="hidden md:flex flex-wrap">
        {team
        |> TeamInfo.tags
        |> Js.Array.map(tag =>
          <div
            className="bg-gray-300 rounded mt-1 mr-1 py-px px-2 text-tiny text-gray-900" key={tag}>
            {str(tag)}
          </div>
        )
        |> React.array}
      </div>
    : React.null
}

let showStudent = (team, levels, teamCoaches) => {
  let student = TeamInfo.students(team)[0]
  <Link
    href={"/students/" ++ ((student |> TeamInfo.studentId) ++ "/report")}
    key={student |> TeamInfo.studentId}
    ariaLabel={"student: " ++ (student |> TeamInfo.studentName)}
    className="flex md:flex-row justify-between bg-white mt-4 rounded-lg shadow cursor-pointer hover:border-primary-500 hover:text-primary-500 hover:shadow-md focus-within:outline-none focus-within:ring-2 focus-within:ring-inset focus-within:ring-focusColor-500">
    <div className="flex flex-1 flex-col justify-center md:flex-row md:w-3/5">
      <div className="flex w-full items-start md:items-center p-3 md:px-4 md:py-5">
        {CoursesStudents__TeamCoaches.avatar(
          student |> TeamInfo.studentAvatarUrl,
          student |> TeamInfo.studentName,
        )}
        <div className="ml-2 md:ml-3 block text-sm md:pr-2">
          <p className="font-semibold inline-block leading-snug">
            {student |> TeamInfo.studentName |> str}
          </p>
          <div className="py-px text-gray-600 text-xs leading-snug flex items-start">
            <span className="font-semibold pr-2"> {student |> TeamInfo.studentTitle |> str} </span>
            <span className="pl-2 border-l border-gray-400 italic">
              {switch student->TeamInfo.lastSeenAt {
              | Some(date) =>
                t(
                  ~variables=[
                    ("time_string", date->DateFns.formatDistanceToNowStrict(~addSuffix=true, ())),
                  ],
                  "last_seen",
                )->str
              | None => t("no_last_seen")->str
              }}
            </span>
          </div>
          <div className="text-gray-600 font-semibold text-xs leading-snug flex items-start">
            {studentTags(student)} {teamTags(team)}
          </div>
        </div>
      </div>
    </div>
    <div
      ariaLabel={"team level info:" ++ (team |> TeamInfo.id)}
      className="w-2/5 flex items-center justify-end md:justify-between p-3 md:p-4">
      <CoursesStudents__TeamCoaches
        title={<div className="mb-1 font-semibold text-gray-800 text-tiny uppercase">
          {tr("personal_coaches") |> str}
        </div>}
        className="hidden md:inline-block"
        coaches=teamCoaches
      />
      {levelInfo(team |> TeamInfo.levelId, levels)}
    </div>
  </Link>
}

let showTeam = (team, levels, teamCoaches) =>
  <Spread props={"data-team-id": TeamInfo.id(team)} key={TeamInfo.id(team)}>
    <div
      key={team |> TeamInfo.id}
      ariaLabel={"Info of team " ++ (team |> TeamInfo.name)}
      className="flex shadow bg-white rounded-lg mt-4 overflow-hidden flex-col-reverse md:flex-row">
      <div className="flex flex-col flex-1 w-full md:w-3/5">
        {team
        |> TeamInfo.students
        |> Array.map(student =>
          <Link
            href={"/students/" ++ ((student |> TeamInfo.studentId) ++ "/report")}
            key={student |> TeamInfo.studentId}
            ariaLabel={"Student: " ++
            (student |> TeamInfo.studentName) ++
            " in team " ++
            (team |> TeamInfo.name)}
            className="flex items-center rounded-l-lg bg-white cursor-pointer hover:border-primary-500 hover:text-primary-500 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500">
            <div className="flex w-full md:flex-1 p-3 md:px-4 md:py-5">
              {CoursesStudents__TeamCoaches.avatar(
                student |> TeamInfo.studentAvatarUrl,
                student |> TeamInfo.studentName,
              )}
              <div className="ml-2 md:ml-3 text-sm flex flex-col">
                <p className="font-semibold inline-block leading-snug ">
                  {student |> TeamInfo.studentName |> str}
                </p>
                <div className="py-px text-gray-600 text-xs leading-snug flex items-start">
                  <span className="font-semibold pr-2">
                    {student |> TeamInfo.studentTitle |> str}
                  </span>
                  <span className="pl-2 border-l border-gray-400 italic">
                    {switch student->TeamInfo.lastSeenAt {
                    | Some(date) =>
                      t(
                        ~variables=[
                          (
                            "time_string",
                            date->DateFns.formatDistanceToNowStrict(~addSuffix=true, ()),
                          ),
                        ],
                        "last_seen",
                      )->str
                    | None => t("no_last_seen")->str
                    }}
                  </span>
                </div>
                {studentTags(student)}
              </div>
            </div>
          </Link>
        )
        |> React.array}
      </div>
      <div
        className="flex w-full md:w-2/5 items-center bg-gray-50 md:bg-white border-l py-2 md:py-0 px-3 md:px-4">
        <div className="flex-1 pb-3 md:py-3 pr-3">
          <div>
            <p
              className="inline-block leading-tight font-semibold text-gray-800 text-tiny uppercase">
              {ts("team") |> str}
            </p>
            <h3 className="text-sm font-semibold leading-snug"> {team |> TeamInfo.name |> str} </h3>
            {teamTags(team)}
            <CoursesStudents__TeamCoaches
              title={<div className="font-semibold text-gray-800 text-tiny uppercase pb-1 ">
                {tr("team_coaches") |> str}
              </div>}
              className="hidden md:inline-block mt-6"
              coaches=teamCoaches
            />
          </div>
        </div>
        <div ariaLabel={"team level info: " ++ (team |> TeamInfo.id)} className="flex-shrink-0">
          {levelInfo(team |> TeamInfo.levelId, levels)}
        </div>
      </div>
    </div>
  </Spread>

@react.component
let make = (~levels, ~teams, ~teamCoaches) =>
  <div>
    {teams |> ArrayUtils.isEmpty
      ? <div className="course-review__reviewed-empty text-lg font-semibold text-center py-4">
          <h4 className="py-4 mt-4 bg-gray-50 text-gray-800 font-semibold">
            {tr("no_teams") |> str}
          </h4>
        </div>
      : teams
        |> Array.map(team => {
          let coaches = team |> TeamInfo.coaches(teamCoaches)

          Array.length(team |> TeamInfo.students) == 1
            ? showStudent(team, levels, coaches)
            : showTeam(team, levels, coaches)
        })
        |> React.array}
  </div>
