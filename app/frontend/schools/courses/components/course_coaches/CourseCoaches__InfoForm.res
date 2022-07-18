open CourseCoaches__Types

let str = React.string

let tr = I18n.t(~scope="components.CourseCoaches__InfoForm")

type rec state = {
  students: array<Student.t>,
  loading: bool,
  stats: stats,
}
and stats = {
  reviewedSubmissions: int,
  pendingSubmissions: int,
}

let initialStats = {reviewedSubmissions: 0, pendingSubmissions: 0}
let initialState = {students: [], loading: true, stats: initialStats}

type action =
  | LoadCoachInfo(array<Student.t>, stats)
  | RemoveStudent(string)

let reducer = (state, action) =>
  switch action {
  | LoadCoachInfo(students, stats) => {students, stats, loading: false}
  | RemoveStudent(id) => {
      ...state,
      students: state.students |> Js.Array.filter(student => Student.id(student) != id),
    }
  }

module CoachInfoQuery = %graphql(`
    query CoachInfoQuery($courseId: ID!, $coachId: ID!, $filterString: String!) {
      courseStudents(courseId: $courseId, filterString: $filterString, first: 100 ) {
        nodes {
          id,
          user {
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

let loadCoachStudents = (courseId, coachId, send) => {
  let filterString =
    Webapi.Url.URLSearchParams.makeWithArray([
      ("personal_coach", coachId),
    ])->Webapi.Url.URLSearchParams.toString

  CoachInfoQuery.fetch({courseId, coachId, filterString})
  |> Js.Promise.then_((result: CoachInfoQuery.t) => {
    let stats = {
      reviewedSubmissions: result.coachStats.reviewedSubmissions,
      pendingSubmissions: result.coachStats.pendingSubmissions,
    }

    send(
      LoadCoachInfo(
        result.courseStudents.nodes->Js.Array2.map(s => Student.make(~id=s.id, ~name=s.user.name)),
        stats,
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}
let removeStudentEnrollment = (send, studentId) => send(RemoveStudent(studentId))

@react.component
let make = (~courseId, ~coach) => {
  let (state, send) = React.useReducer(reducer, initialState)

  React.useEffect1(() => {
    loadCoachStudents(courseId, coach |> CourseCoach.id, send)
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
              className="w-full mr-2 rounded-lg shadow px-5 py-6"
              ariaLabel={tr("revied_submissions")}>
              <div className="flex justify-between items-center">
                <span> {tr("revied_submissions") |> str} </span>
                <span className="text-2xl font-semibold">
                  {state.stats.reviewedSubmissions |> string_of_int |> str}
                </span>
              </div>
            </div>
            <div
              className="w-full ml-2 rounded-lg shadow px-5 py-6"
              ariaLabel={tr("pending_submissions")}>
              <div className="flex justify-between items-center">
                <span> {tr("pending_submissions") |> str} </span>
                <span className="text-2xl font-semibold">
                  {state.stats.pendingSubmissions |> string_of_int |> str}
                </span>
              </div>
            </div>
          </div>}
      <span className="inline-block mr-1 my-2 text-sm font-semibold pt-5">
        {tr("students_assigned") |> str}
      </span>
      {state.loading
        ? <div className="max-w-2xl mx-auto p-3">
            {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.paragraph())}
          </div>
        : <div>
            {state.students |> ArrayUtils.isEmpty
              ? <div
                  className="border border-gray-300 rounded italic text-gray-600 text-xs cursor-default mt-2 p-3">
                  {tr("no_students_assigned") |> str}
                </div>
              : state.students
                |> Array.map(student =>
                  <CourseCoaches__InfoFormStudent
                    key={Student.id(student)}
                    student
                    coach
                    removeStudentEnrollmentCB={removeStudentEnrollment(send)}
                  />
                )
                |> React.array}
          </div>}
    </div>
  </div>
}
