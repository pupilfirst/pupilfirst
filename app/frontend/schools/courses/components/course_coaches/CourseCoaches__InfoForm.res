open CourseCoaches__Types

let str = React.string

let tr = I18n.t(~scope="components.CourseCoaches__InfoForm", ...)
let ts = I18n.t(~scope="shared", ...)

type rec state = {
  students: array<Student.t>,
  loading: bool,
  stats: stats,
  cohorts: array<Cohort.t>,
  assignedCohorts: array<Cohort.t>,
  cohortSearchInput: string,
  dirty: bool,
  saving: bool,
}
and stats = {
  reviewedSubmissions: int,
  pendingSubmissions: int,
}

let initialStats = {reviewedSubmissions: 0, pendingSubmissions: 0}
let initialState = {
  students: [],
  loading: true,
  stats: initialStats,
  cohorts: [],
  assignedCohorts: [],
  cohortSearchInput: "",
  dirty: false,
  saving: false,
}

type action =
  | LoadCoachInfo(array<Student.t>, stats, array<Cohort.t>, array<Cohort.t>)
  | SelectCohort(Cohort.t)
  | DeSelectCohort(Cohort.t)
  | UpdateCohortSearchInput(string)
  | RemoveStudent(string)
  | UpdateStatusSuccess
  | SetSaving
  | ClearSaving

let reducer = (state, action) =>
  switch action {
  | LoadCoachInfo(students, stats, cohorts, assignedCohorts) => {
      ...state,
      students,
      stats,
      loading: false,
      cohorts,
      assignedCohorts,
    }
  | RemoveStudent(id) => {
      ...state,
      students: Js.Array.filter(student => Student.id(student) != id, state.students),
    }
  | UpdateCohortSearchInput(cohortSearchInput) => {...state, cohortSearchInput}
  | SelectCohort(cohort) => {
      ...state,
      assignedCohorts: Js.Array2.concat(state.assignedCohorts, [cohort]),
      dirty: true,
    }
  | DeSelectCohort(cohort) => {
      ...state,
      assignedCohorts: state.assignedCohorts->Js.Array2.filter(c =>
        Cohort.id(c) != Cohort.id(cohort)
      ),
      dirty: true,
    }
  | SetSaving => {
      ...state,
      saving: true,
    }
  | ClearSaving => {
      ...state,
      saving: false,
    }
  | UpdateStatusSuccess => {
      ...state,
      saving: false,
      dirty: false,
    }
  }

module CohortFragment = Cohort.Fragment

module CoachInfoQuery = %graphql(`
    query CoachInfoQuery($courseId: ID!, $coachId: ID!) {
      coach(id: $coachId) {
        cohorts(courseId: $courseId) {
          ...CohortFragment
        }
        students(courseId: $courseId) {
          id,
          user {
            name
          }
        }
      }

      course(id: $courseId) {
        cohorts {
          ...CohortFragment
        }
      }

      coachStats(courseId: $courseId, coachId: $coachId) {
        reviewedSubmissions
        pendingSubmissions
      }
    }
  `)

let loadCoachStudents = (courseId, coachId, send) => {
  ignore(Js.Promise.then_((result: CoachInfoQuery.t) => {
      let stats = {
        reviewedSubmissions: result.coachStats.reviewedSubmissions,
        pendingSubmissions: result.coachStats.pendingSubmissions,
      }

      send(
        LoadCoachInfo(
          result.coach.students->Js.Array2.map(s => Student.make(~id=s.id, ~name=s.user.name)),
          stats,
          result.course.cohorts->Js.Array2.map(Cohort.makeFromFragment),
          result.coach.cohorts->Js.Array2.map(Cohort.makeFromFragment),
        ),
      )
      Js.Promise.resolve()
    }, CoachInfoQuery.fetch({courseId, coachId})))
}
let removeStudentEnrollment = (send, studentId) => send(RemoveStudent(studentId))

module SelectableCohort = {
  type t = Cohort.t
  let value = t => t->Cohort.name
  let searchString = value
}

module MultiselectForCohorts = MultiselectInline.Make(SelectableCohort)

let courseCohortPicker = (cohorts, state, send) => {
  let selected = state.assignedCohorts
  let selectedCohortIds = selected->Js.Array2.map(s => Cohort.id(s))

  let unselected = cohorts->Js.Array2.filter(s => !Array.mem(Cohort.id(s), selectedCohortIds))

  <MultiselectForCohorts
    placeholder={tr("search_cohorts_placeholder")}
    emptySelectionMessage={tr("search_cohorts_empty")}
    allItemsSelectedMessage={tr("search_cohorts_all")}
    selected
    unselected
    onChange={value => send(UpdateCohortSearchInput(value))}
    value=state.cohortSearchInput
    onSelect={s => send(SelectCohort(s))}
    onDeselect={s => send(DeSelectCohort(s))}
  />
}

let handleResponseCB = (send, _json) => {
  Notification.success(ts("notifications.success"), tr("notification_coach_updated"))
  send(UpdateStatusSuccess)
}

let makePayload = (state, coach) => {
  let payload = Js.Dict.empty()

  Js.Dict.set(payload, "authenticity_token", Js.Json.string(AuthenticityToken.fromHead()))

  Js.Dict.set(
    payload,
    "coach_ids",
    {
      open Json.Encode
      array(string)
    }([CourseCoach.id(coach)]),
  )

  Js.Dict.set(
    payload,
    "cohort_ids",
    {
      open Json.Encode
      array(string)
    }(state.assignedCohorts->Js.Array2.map(Cohort.id)),
  )

  payload
}

let updateCourseCoaches = (state, send, courseId, coach) => {
  send(SetSaving)

  let payload = makePayload(state, coach)
  let url = "/school/courses/" ++ (courseId ++ "/update_coach_enrollments")

  Api.create(url, payload, handleResponseCB(send), () => send(ClearSaving))
}

@react.component
let make = (~courseId, ~coach) => {
  let (state, send) = React.useReducer(reducer, initialState)

  React.useEffect1(() => {
    loadCoachStudents(courseId, CourseCoach.id(coach), send)
    None
  }, [courseId])
  <div className="mx-auto">
    <div className="py-6 border-b border-gray-300 bg-gray-50">
      <div className="max-w-2xl mx-auto">
        <div className="flex">
          {switch CourseCoach.avatarUrl(coach) {
          | Some(avatarUrl) => <img className="w-12 h-12 rounded-full me-4" src=avatarUrl />
          | None => <Avatar name={CourseCoach.name(coach)} className="w-12 h-12 me-4" />
          }}
          <div className="text-sm flex flex-col justify-center">
            <div className="text-black font-bold inline-block">
              {str(CourseCoach.name(coach))}
            </div>
            <div className="text-gray-600 inline-block"> {str(CourseCoach.email(coach))} </div>
          </div>
        </div>
      </div>
    </div>
    <div className="max-w-2xl mx-auto pb-5">
      {state.loading
        ? <div className="py-3 flex">
            {SkeletonLoading.card(~className="w-full me-2", ())}
            {SkeletonLoading.card(~className="w-full ms-2", ())}
          </div>
        : <div className="py-3 flex mt-4">
            <div
              className="w-full me-2 rounded-lg shadow px-5 py-6"
              ariaLabel={tr("revied_submissions")}>
              <div className="flex justify-between items-center">
                <span> {str(tr("revied_submissions"))} </span>
                <span className="text-2xl font-semibold">
                  {str(string_of_int(state.stats.reviewedSubmissions))}
                </span>
              </div>
            </div>
            <div
              className="w-full ms-2 rounded-lg shadow px-5 py-6"
              ariaLabel={tr("pending_submissions")}>
              <div className="flex justify-between items-center">
                <span> {str(tr("pending_submissions"))} </span>
                <span className="text-2xl font-semibold">
                  {str(string_of_int(state.stats.pendingSubmissions))}
                </span>
              </div>
            </div>
          </div>}
      <span className="inline-block me-1 my-2 text-sm font-semibold pt-5">
        {str(tr("students_assigned"))}
      </span>
      {state.loading
        ? <div className="max-w-2xl mx-auto p-3">
            {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.paragraph())}
          </div>
        : <div>
            {ArrayUtils.isEmpty(state.students)
              ? <div
                  className="border border-gray-300 rounded italic text-gray-600 text-xs cursor-default mt-2 p-3">
                  {str(tr("no_students_assigned"))}
                </div>
              : React.array(
                  Array.map(
                    student =>
                      <CourseCoaches__InfoFormStudent
                        key={Student.id(student)}
                        student
                        coach
                        removeStudentEnrollmentCB={removeStudentEnrollment(send)}
                      />,
                    state.students,
                  ),
                )}
          </div>}
      <div>
        <span className="inline-block me-1 my-2 text-sm font-semibold pt-5">
          {tr("select_cohorts")->str}
        </span>
        {state.loading
          ? <div className="max-w-5xl mx-auto px-2 mt-8"> {SkeletonLoading.input()} </div>
          : courseCohortPicker(state.cohorts, state, send)}
        <div className="flex max-w-2xl w-full mt-5 mx-auto">
          <button
            disabled={state.loading || state.saving || !state.dirty}
            onClick={_e => updateCourseCoaches(state, send, courseId, coach)}
            className="w-full btn btn-primary btn-large">
            {str(tr("update_cohort_assignment"))}
          </button>
        </div>
      </div>
    </div>
  </div>
}
