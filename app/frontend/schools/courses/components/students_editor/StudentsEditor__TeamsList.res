@module("./images/no-students-found.svg") external notFoundIcon: string = "default"

let str = React.string

open StudentsEditor__Types

let t = I18n.t(~scope="components.StudentsEditor__TeamsList")

module CourseTeamsQuery = %graphql(`
    query CourseTeamsQuery($courseId: ID!, $levelId: ID, $search: String, $after: String, $tags: [String!], $sortBy: String!, $sortDirection: SortDirection!) {
      courseTeams(courseId: $courseId, levelId: $levelId, search: $search, first: 20, after: $after, tags: $tags, sortBy: $sortBy, sortDirection: $sortDirection) {
        nodes {
          id,
          name,
          teamTags,
          levelId,
          coachIds,
          accessEndsAt
          students {
            id,
            name,
            title,
            avatarUrl,
            userTags,
            email,
            affiliation
            issuedCertificates {
              id
              certificateId
              serialNumber
              revokedBy
              revokedAt
              createdAt
              issuedBy
            }
          }
        }
        pageInfo {
          endCursor,hasNextPage
        }
        totalCount
      }
    }
  `)

let updateTeams = (updateTeamsCB, endCursor, hasNextPage, teams, totalCount, nodes) => {
  let updatedTeams = Js.Array.concat(Team.makeFromJS(nodes), teams)

  let teams = switch (hasNextPage, endCursor) {
  | (_, None)
  | (false, Some(_)) =>
    Page.FullyLoaded(updatedTeams)
  | (true, Some(cursor)) => Page.PartiallyLoaded(updatedTeams, cursor)
  }

  updateTeamsCB(teams, totalCount)
}

let getTeams = (courseId, cursor, updateTeamsCB, teams, filter, setLoadingCB, loading) => {
  let tags = filter->Filter.tags
  let selectedLevelId = filter->Filter.levelId
  let search = filter->Filter.searchString
  let sortBy = filter->Filter.sortByToString
  let sortDirection = filter->Filter.sortDirection
  setLoadingCB(loading)
  CourseTeamsQuery.make({
    courseId: courseId,
    levelId: selectedLevelId,
    search: search,
    after: cursor,
    tags: Some(tags),
    sortBy: sortBy,
    sortDirection: sortDirection,
  })
  |> Js.Promise.then_(response => {
    response["courseTeams"]["nodes"] |> updateTeams(
      updateTeamsCB,
      response["courseTeams"]["pageInfo"]["endCursor"],
      response["courseTeams"]["pageInfo"]["hasNextPage"],
      teams,
      response["courseTeams"]["totalCount"],
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let studentAvatar = student =>
  switch student |> Student.avatarUrl {
  | Some(avatarUrl) =>
    <img
      className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden flex-shrink-0 mt-1 md:mt-0 mr-2 md:mr-3 object-cover"
      src=avatarUrl
    />
  | None =>
    <Avatar
      name={student |> Student.name}
      className="w-8 h-8 md:w-10 md:h-10 text-xs border rounded-full overflow-hidden flex-shrink-0 mt-1 md:mt-0 mr-2 md:mr-3 object-cover"
    />
  }

let levelInfo = (levels, team) =>
  <span
    className="inline-flex flex-col items-center rounded bg-orange-100 border border-orange-300 px-2 pt-2 pb-1">
    <div className="text-xs font-semibold"> {t("level")->str} </div>
    <div className="font-bold">
      {team
      |> Team.levelId
      |> Level.unsafeFind(levels, "TeamsList")
      |> Level.number
      |> string_of_int
      |> str}
    </div>
  </span>

let userTags = student =>
  <div className="flex flex-wrap">
    {student
    |> Student.userTags
    |> Js.Array.map(tag =>
      <div key=tag className="bg-blue-100 rounded mt-1 mr-1 py-px px-2 text-xs text-gray-900">
        {tag |> str}
      </div>
    )
    |> React.array}
  </div>

let teamTags = team =>
  <div className="flex flex-wrap">
    {team
    |> Team.tags
    |> Array.map(tag =>
      <div key=tag className="bg-gray-300 rounded mt-1 mr-1 py-px px-2 text-xs text-gray-900">
        {tag |> str}
      </div>
    )
    |> React.array}
  </div>

let teamCard = (
  team,
  selectedStudentIds,
  selectStudentCB,
  deselectStudentCB,
  showEditFormCB,
  levels,
) => {
  let isSingleStudent = team |> Team.isSingleStudent
  let teamId = team |> Team.id
  <div
    key=teamId
    id={team |> Team.name}
    className="student-team-container flex items-strecth shadow bg-white rounded-lg mb-3 overflow-hidden">
    <div className="flex flex-col flex-1 w-3/5">
      {team
      |> Team.students
      |> Array.map(student => {
        let studentId = student |> Student.id
        let isChecked = selectedStudentIds |> Array.mem(studentId)
        let checkboxId = "select-student-" ++ studentId

        <div
          key=studentId
          id={student |> Student.name}
          className="student-team__card h-full cursor-pointer flex items-center bg-white">
          <div className="flex flex-1 w-3/5 h-full">
            <div className="flex items-center w-full">
              <div className="relative pl-4">
                <Checkbox
                  id={checkboxId}
                  onChange={isChecked
                    ? _e => deselectStudentCB(studentId)
                    : _e => selectStudentCB(student, team)}
                  checked={isChecked}
                />
              </div>
              <button
                className="flex flex-1 items-center text-left py-4 px-4 hover:bg-gray-50 hover:text-primary-500 focus:bg-gray-50 focus:text-primary-500 justify-between"
                id={(student |> Student.name) ++ "_edit"}
                ariaLabel={"View and edit " ++ (student |> Student.name)}
                onClick={_e => showEditFormCB(student, teamId)}>
                <div className="flex">
                  {studentAvatar(student)}
                  <div className="text-sm flex flex-col">
                    <p className="font-semibold inline-block ">
                      {student |> Student.name |> str}
                    </p>
                    <span className="flex flex-row">
                      {userTags(student)} {isSingleStudent ? teamTags(team) : React.null}
                    </span>
                  </div>
                </div>
                {isSingleStudent ? team |> levelInfo(levels) : React.null}
              </button>
            </div>
          </div>
        </div>
      })
      |> React.array}
    </div>
    {isSingleStudent
      ? React.null
      : <div className="flex w-2/5 items-center border-l border-gray-50">
          <div className="w-2/3 py-4 pl-5 pr-4">
            <div className="students-team--name mb-5">
              <p className="inline-block text-xs bg-green-200 leading-tight px-1 py-px rounded">
                {t("team")->str}
              </p>
              <h4> {team |> Team.name |> str} </h4>
              {teamTags(team)}
            </div>
          </div>
          <div className="w-1/3 text-right pr-4"> {team |> levelInfo(levels)} </div>
        </div>}
  </div>
}

let showEmpty = (filter, loading, updateFilterCB) =>
  loading == Loading.NotLoading && filter->Filter.isEmpty
    ? <div className="text-center"> {t("empty_message")->str} </div>
    : <div className="flex">
        <div className="w-1/2 px-3">
          <p className="text-xl font-semibold mt-4"> {t("no_results_found")->str} </p>
          <ul className="list-disc text-gray-800 text-sm ml-5 mt-2">
            <li className="py-1"> {t("check_spelling")->str} </li>
            <li className="py-1"> {t("try_removing_filter")->str} </li>
          </ul>
          <button
            className="btn btn-default mt-4" onClick={_ => updateFilterCB(filter->Filter.clear)}>
            {t("clear_filter")->str}
          </button>
        </div>
        <div className="w-1/2"> <img className="w-full" src=notFoundIcon /> </div>
      </div>

let showTeams = (
  selectedStudentIds,
  selectStudentCB,
  deselectStudentCB,
  showEditFormCB,
  levels,
  filter,
  updateFilterCB,
  loading,
  teams,
) =>
  switch teams {
  | [] => showEmpty(filter, loading, updateFilterCB)
  | teams =>
    teams
    |> Array.map(team =>
      teamCard(team, selectedStudentIds, selectStudentCB, deselectStudentCB, showEditFormCB, levels)
    )
    |> React.array
  }

let submissionsLoadedData = (totalStudentsCount, loadedStudentsCount) =>
  <div className="text-center pb-4">
    <div className="inline-block mt-2 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
      {str(
        totalStudentsCount == loadedStudentsCount
          ? t(~count=loadedStudentsCount, "students_fully_loaded_text")
          : t(
              ~count=loadedStudentsCount,
              ~variables=[
                ("total_students", string_of_int(totalStudentsCount)),
                ("loaded_students_count", string_of_int(loadedStudentsCount)),
              ],
              "students_partially_loaded_text",
            ),
      )}
    </div>
  </div>

@react.component
let make = (
  ~levels,
  ~courseId,
  ~updateTeamsCB,
  ~filter,
  ~pagedTeams,
  ~totalTeamsCount,
  ~selectedStudentIds,
  ~selectStudentCB,
  ~deselectStudentCB,
  ~showEditFormCB,
  ~loading,
  ~setLoadingCB,
  ~updateFilterCB,
  ~refreshTeams,
) => {
  React.useEffect1(() => {
    getTeams(courseId, None, updateTeamsCB, [], filter, setLoadingCB, Loading.Reloading)

    None
  }, [refreshTeams])

  <div className="pb-6">
    <div className="max-w-3xl mx-auto w-full">
      <div>
        {switch (pagedTeams: Page.t) {
        | Unloaded => SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
        | PartiallyLoaded(_, _)
        | FullyLoaded(_) =>
          pagedTeams
          |> Page.teams
          |> showTeams(
            selectedStudentIds,
            selectStudentCB,
            deselectStudentCB,
            showEditFormCB,
            levels,
            filter,
            updateFilterCB,
            loading,
          )
        }}
      </div>
      {ReactUtils.nullIf(
        submissionsLoadedData(totalTeamsCount, Array.length(pagedTeams->Page.teams)),
        totalTeamsCount == 0,
      )}
      {switch (pagedTeams: Page.t) {
      | Unloaded
      | FullyLoaded(_) => React.null
      | PartiallyLoaded(teams, cursor) =>
        loading == Loading.LoadingMore
          ? SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
          : <div className="pt-4">
              <button
                className="btn btn-primary-ghost cursor-pointer w-full"
                onClick={_ =>
                  getTeams(
                    courseId,
                    Some(cursor),
                    updateTeamsCB,
                    teams,
                    filter,
                    setLoadingCB,
                    Loading.LoadingMore,
                  )}>
                {t("load_more")->str}
              </button>
            </div>
      }}
    </div>
  </div>
}
