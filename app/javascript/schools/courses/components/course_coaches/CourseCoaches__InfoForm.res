open CourseCoaches__Types

let str = React.string

let tr = I18n.t(~scope="components.CourseCoaches__InfoForm")

type rec state = {
  teams: array<Team.t>,
  loading: bool,
  stats: stats,
}
and stats = {
  reviewedSubmissions: int,
  pendingSubmissions: int,
}

let initialStats = {reviewedSubmissions: 0, pendingSubmissions: 0}
let initialState = {teams: [], loading: true, stats: initialStats}

type action =
  | LoadCoachInfo(array<Team.t>, stats)
  | RemoveTeam(string)

let reducer = (state, action) =>
  switch action {
  | LoadCoachInfo(teams, stats) => {teams: teams, stats: stats, loading: false}
  | RemoveTeam(id) => {
      ...state,
      teams: state.teams |> Js.Array.filter(team => Team.id(team) != id),
    }
  }

module CoachInfoQuery = %graphql(`
    query CoachInfoQuery($courseId: ID!, $coachId: ID!, $coachNotes: CoachNoteFilter!) {
      teams(courseId: $courseId, coachNotes: $coachNotes, coachId: $coachId, first: 100, tags: []) {
        nodes {
          id,
          name,
          students {
            name
          }
        }
      }

      coachStats(courseId: $courseId, coachId: $coachId) {
        reviewedSubmissions
        pendingSubmissions
      }
    }
  `)

let loadCoachTeams = (courseId, coachId, send) =>
  CoachInfoQuery.make({courseId: courseId, coachId: coachId, coachNotes: #IgnoreCoachNotes})
  |> Js.Promise.then_(result => {
    let stats = {
      reviewedSubmissions: result["coachStats"]["reviewedSubmissions"],
      pendingSubmissions: result["coachStats"]["pendingSubmissions"],
    }

    send(LoadCoachInfo(Team.makeArrayFromJs(result["teams"]["nodes"]), stats))
    Js.Promise.resolve()
  })
  |> ignore

let removeTeamEnrollment = (send, teamId) => send(RemoveTeam(teamId))

@react.component
let make = (~courseId, ~coach) => {
  let (state, send) = React.useReducer(reducer, initialState)

  React.useEffect1(() => {
    loadCoachTeams(courseId, coach |> CourseCoach.id, send)
    None
  }, [courseId])
  <div className="mx-auto">
    <div className="py-6 border-b border-gray-300 bg-gray-50">
      <div className="max-w-2xl mx-auto">
        <div className="flex">
          {switch coach |> CourseCoach.avatarUrl {
          | Some(avatarUrl) => <img className="w-12 h-12 rounded-full mr-4" src=avatarUrl />
          | None => <Avatar name={coach |> CourseCoach.name} className="w-12 h-12 mr-4" />
          }}
          <div className="text-sm flex flex-col justify-center">
            <div className="text-black font-bold inline-block">
              {coach |> CourseCoach.name |> str}
            </div>
            <div className="text-gray-600 inline-block"> {coach |> CourseCoach.email |> str} </div>
          </div>
        </div>
      </div>
    </div>
    <div className="max-w-2xl mx-auto">
      {state.loading
        ? <div className="py-3 flex">
            {SkeletonLoading.card(~className="w-full mr-2", ())}
            {SkeletonLoading.card(~className="w-full ml-2", ())}
          </div>
        : <div className="py-3 flex mt-4">
            <div
              className="w-full mr-2 rounded-lg shadow px-5 py-6" ariaLabel=tr("revied_submissions")>
              <div className="flex justify-between items-center">
                <span> {tr("revied_submissions") |> str} </span>
                <span className="text-2xl font-semibold">
                  {state.stats.reviewedSubmissions |> string_of_int |> str}
                </span>
              </div>
            </div>
            <div
              className="w-full ml-2 rounded-lg shadow px-5 py-6" ariaLabel=tr("pending_submissions")>
              <div className="flex justify-between items-center">
                <span> {tr("pending_submissions") |> str} </span>
                <span className="text-2xl font-semibold">
                  {state.stats.pendingSubmissions |> string_of_int |> str}
                </span>
              </div>
            </div>
          </div>}
      <span className="inline-block mr-1 my-2 text-sm font-semibold pt-5">
        { tr("students_assigned") |> str}
      </span>
      {state.loading
        ? <div className="max-w-2xl mx-auto p-3">
            {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.paragraph())}
          </div>
        : <div>
            {state.teams |> ArrayUtils.isEmpty
              ? <div
                  className="border border-gray-300 rounded italic text-gray-600 text-xs cursor-default mt-2 p-3">
                  {tr("no_students_assigned") |> str}
                </div>
              : state.teams
                |> Array.map(team =>
                  <CourseCoaches__InfoFormTeam
                    key={Team.id(team)}
                    team
                    coach
                    removeTeamEnrollmentCB={removeTeamEnrollment(send)}
                  />
                )
                |> React.array}
          </div>}
    </div>
  </div>
}
