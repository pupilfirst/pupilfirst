%%raw(`import "./CoursesStudents__StudentOverlay.css"`)

open CoursesStudents__Types
let str = React.string
let t = I18n.t(~scope="components.CoursesStudents__StudentOverlay")
let ts = I18n.t(~scope="shared")

type selectedTab =
  | Notes
  | Submissions

type studentData =
  | Loading
  | Loaded(StudentDetails.t)

type state = {
  selectedTab: selectedTab,
  studentData: studentData,
  submissions: Submissions.t,
}

let initialState = {
  studentData: Loading,
  selectedTab: Notes,
  submissions: Unloaded,
}

let closeOverlayLink = student => {
  let search = Webapi.Dom.window->Webapi.Dom.Window.location->Webapi.Dom.Location.search
  let cohortId = StudentInfo.cohort(student)->Cohort.id
  "/cohorts/" ++ (cohortId ++ "/students") ++ search
}

module UserDetailsFragment = UserDetails.Fragment
module CohortFragment = Cohort.Fragment
module UserProxyFragment = UserProxy.Fragment
module UserFragment = User.Fragment

module StudentDetailsQuery = %graphql(`
    query StudentDetailsQuery($studentId: ID!) {
      studentDetails(studentId: $studentId) {
        email,
        evaluationCriteria {
          id, name, maxGrade, passGrade
        },
        student {
          id,
          taggings
          user {
            ...UserDetailsFragment
          }
          cohort {
            ...CohortFragment
          }
          personalCoaches {
            ...UserProxyFragment
          }
          droppedOutAt
          course {
            id
          }
        }
        totalTargets
        targetsCompleted
        quizScores
        averageGrades {
          evaluationCriterionId
          averageGrade
        }
        milestoneTargetsCompletionStatus {
          id
          title
          milestoneNumber
          completed
        }
        canModifyCoachNotes
        team {
          id
          name
          students {
            id,
            taggings
            user {
              ...UserDetailsFragment
            }
            cohort {
              ...CohortFragment
            }
            personalCoaches {
              ...UserProxyFragment
            }
            droppedOutAt
          }
        }
      }
      coachNotes(studentId: $studentId) {
          id
          note
          createdAt
          author {
          ...UserFragment
        }
      }
      hasArchivedCoachNotes(studentId: $studentId)
    }
  `)

let getStudentDetails = (studentId, setState) => {
  setState(state => {...state, studentData: Loading})
  StudentDetailsQuery.fetch({studentId: studentId})
  |> Js.Promise.then_((response: StudentDetailsQuery.t) => {
    let s = response.studentDetails.student
    let coachNotes =
      response.coachNotes->Js.Array2.map(coachNote =>
        CoachNote.make(
          ~id=coachNote.id,
          ~note=coachNote.note,
          ~createdAt=coachNote.createdAt->DateFns.decodeISO,
          ~author=coachNote.author->Belt.Option.map(User.makeFromFragment),
        )
      )

    let evaluationCriteria =
      response.studentDetails.evaluationCriteria->Js.Array2.map(evaluationCriterion =>
        CoursesStudents__EvaluationCriterion.make(
          ~id=evaluationCriterion.id,
          ~name=evaluationCriterion.name,
          ~maxGrade=evaluationCriterion.maxGrade,
          ~passGrade=evaluationCriterion.passGrade,
        )
      )

    let averageGrades =
      response.studentDetails.averageGrades->Js.Array2.map(gradeData =>
        StudentDetails.makeAverageGrade(
          ~evaluationCriterionId=gradeData.evaluationCriterionId,
          ~grade=gradeData.averageGrade,
        )
      )

    let milestoneTargetsCompletionStatus =
      response.studentDetails.milestoneTargetsCompletionStatus->Js.Array2.map(milestoneTarget =>
        CoursesStudents__MilestoneTargetsCompletionStatus.make(
          ~id=milestoneTarget.id,
          ~title=milestoneTarget.title,
          ~milestoneNumber=milestoneTarget.milestoneNumber,
          ~completed=milestoneTarget.completed,
        )
      )

    let studentDetails = StudentDetails.make(
      ~id=studentId,
      ~hasArchivedNotes=response.hasArchivedCoachNotes,
      ~canModifyCoachNotes=response.studentDetails.canModifyCoachNotes,
      ~coachNotes,
      ~evaluationCriteria,
      ~totalTargets=response.studentDetails.totalTargets,
      ~targetsCompleted=response.studentDetails.targetsCompleted,
      ~quizScores=response.studentDetails.quizScores,
      ~averageGrades,
      ~courseId=response.studentDetails.student.course.id,
      ~student=StudentInfo.make(
        ~id=s.id,
        ~taggings=s.taggings,
        ~user=UserDetails.makeFromFragment(s.user),
        ~cohort=Cohort.makeFromFragment(s.cohort),
        ~droppedOutAt=s.droppedOutAt->Belt.Option.map(DateFns.decodeISO),
        ~personalCoaches=s.personalCoaches->Js.Array2.map(UserProxy.makeFromFragment),
      ),
      ~team=response.studentDetails.team->Belt.Option.map(team =>
        StudentDetails.makeTeam(
          ~id=team.id,
          ~name=team.name,
          ~students=team.students->Js.Array2.map(
            s =>
              StudentInfo.make(
                ~id=s.id,
                ~taggings=s.taggings,
                ~user=UserDetails.makeFromFragment(s.user),
                ~cohort=Cohort.makeFromFragment(s.cohort),
                ~droppedOutAt=s.droppedOutAt->Belt.Option.map(DateFns.decodeISO),
                ~personalCoaches=s.personalCoaches->Js.Array2.map(UserProxy.makeFromFragment),
              ),
          ),
        )
      ),
      ~milestoneTargetsCompletionStatus,
    )

    setState(state => {...state, studentData: Loaded(studentDetails)})
    Js.Promise.resolve()
  })
  |> ignore
}

let updateSubmissions = (setState, submissions) => setState(state => {...state, submissions})

let doughnutChart = (color, percentage) =>
  <svg viewBox="0 0 36 36" className={"student-overlay__doughnut-chart " ++ color}>
    <path
      className="student-overlay__doughnut-chart-bg"
      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
    />
    <path
      className="student-overlay__doughnut-chart-stroke"
      strokeDasharray={percentage ++ ", 100"}
      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
    />
    <text x="50%" y="58%" className="student-overlay__doughnut-chart-text font-semibold">
      {percentage ++ "%" |> str}
    </text>
  </svg>

let targetsCompletionStatus = (targetsCompleted, totalTargets) => {
  let targetCompletionPercent =
    targetsCompleted /. totalTargets *. 100.0 |> int_of_float |> string_of_int
  <div ariaLabel="target-completion-status" className="w-full lg:w-1/2 px-2">
    <div className="student-overlay__doughnut-chart-container bg-gray-50">
      {doughnutChart("purple", targetCompletionPercent)}
      <p className="text-sm font-semibold text-center mt-3">
        {t("total_targets_completed") |> str}
      </p>
      <p className="text-sm text-gray-600 font-semibold text-center mt-1">
        {(targetsCompleted |> int_of_float |> string_of_int) ++
          ("/" ++
          ((totalTargets |> int_of_float |> string_of_int) ++ t("targets"))) |> str}
      </p>
    </div>
  </div>
}

let quizPerformanceChart = (averageQuizScore, quizzesAttempted) =>
  switch averageQuizScore {
  | Some(score) =>
    <div ariaLabel="quiz-performance-chart" className="w-full lg:w-1/2 px-2 mt-2 lg:mt-0">
      <div className="student-overlay__doughnut-chart-container">
        {doughnutChart("pink", score |> int_of_float |> string_of_int)}
        <p className="text-sm font-semibold text-center mt-3"> {t("average_quiz_score") |> str} </p>
        <p className="text-sm text-gray-600 font-semibold text-center leading-tight mt-1">
          {t(~count=quizzesAttempted, "quizzes_attempted")->str}
        </p>
      </div>
    </div>
  | None => React.null
  }

let milestoneTargetsCompletionStats = studentDetails => {
  let milestoneTargets = studentDetails->StudentDetails.milestoneTargetsCompletionStatus

  let totalMilestoneTargets = Js.Array2.length(milestoneTargets)

  let completedMilestoneTargets =
    milestoneTargets->Js.Array2.filter(target => target.completed == true)->Js.Array2.length

  let milestoneTargetCompletionPercentage = string_of_int(
    int_of_float(
      float_of_int(completedMilestoneTargets) /. float_of_int(totalMilestoneTargets) *. 100.0,
    ),
  )

  <div className="flex items-center gap-2 flex-shrink-0">
    <p className="text-xs font-medium text-gray-500">
      {(completedMilestoneTargets->string_of_int ++ " / " ++ totalMilestoneTargets->string_of_int)
        ->str}
      <span className="px-2 text-gray-300"> {"|"->str} </span>
      {ts(
        "percentage_completed",
        ~variables=[("percentage", milestoneTargetCompletionPercentage)],
      )->str}
    </p>
    <div>
      <svg viewBox="0 0 36 36" className="courses-milestone-complete__doughnut-chart ">
        <path
          className="courses-milestone-complete__doughnut-chart-bg "
          d="M18 2.0845
            a 15.9155 15.9155 0 0 1 0 31.831
            a 15.9155 15.9155 0 0 1 0 -31.831"
        />
        <path
          className="courses-milestone-complete__doughnut-chart-stroke"
          strokeDasharray={milestoneTargetCompletionPercentage ++ ", 100"}
          d="M18 2.0845
            a 15.9155 15.9155 0 0 1 0 31.831
            a 15.9155 15.9155 0 0 1 0 -31.831"
        />
      </svg>
    </div>
  </div>
}

let averageGradeCharts = (
  evaluationCriteria: array<CoursesStudents__EvaluationCriterion.t>,
  averageGrades: array<StudentDetails.averageGrade>,
) =>
  averageGrades
  |> Array.map(grade => {
    let criterion = StudentDetails.evaluationCriterionForGrade(
      grade,
      evaluationCriteria,
      "CoursesStudents__StudentOverlay",
    )
    let passGrade = criterion |> CoursesStudents__EvaluationCriterion.passGrade |> float_of_int
    let averageGrade = grade |> StudentDetails.gradeValue
    <div
      ariaLabel={"average-grade-for-criterion-" ++
      (criterion |> CoursesStudents__EvaluationCriterion.id)}
      key={criterion |> CoursesStudents__EvaluationCriterion.id}
      className="flex w-full lg:w-1/2 px-2 mt-2">
      <div className="student-overlay__pie-chart-container">
        <div className="flex px-5 pt-4 text-center items-center">
          <svg
            className={"student-overlay__pie-chart " ++ (
              averageGrade < passGrade
                ? "student-overlay__pie-chart--fail"
                : "student-overlay__pie-chart--pass"
            )}
            viewBox="0 0 32 32">
            <circle
              className={"student-overlay__pie-chart-circle " ++ (
                averageGrade < passGrade
                  ? "student-overlay__pie-chart-circle--fail"
                  : "student-overlay__pie-chart-circle--pass"
              )}
              strokeDasharray={StudentDetails.gradeAsPercentage(grade, criterion) ++ ", 100"}
              r="16"
              cx="16"
              cy="16"
            />
          </svg>
          <span className="ms-3 text-lg font-semibold">
            {(grade.grade |> Js.Float.toString) ++ ("/" ++ (criterion.maxGrade |> string_of_int))
              |> str}
          </span>
        </div>
        <p className="text-sm font-semibold px-5 pt-3 pb-4">
          {criterion |> CoursesStudents__EvaluationCriterion.name |> str}
        </p>
      </div>
    </div>
  })
  |> React.array

let test = (value, url) => {
  let tester = Js.Re.fromString(value)
  url |> Js.Re.test_(tester)
}

let socialLinkIconClass = url =>
  switch url {
  | url if url |> test("twitter") => "fab fa-twitter"
  | url if url |> test("facebook") => "fab fa-facebook-f"
  | url if url |> test("instagram") => "fab fa-instagram"
  | url if url |> test("youtube") => "fab fa-youtube"
  | url if url |> test("linkedin") => "fab fa-linkedin"
  | url if url |> test("reddit") => "fab fa-reddit"
  | url if url |> test("flickr") => "fab fa-flickr"
  | url if url |> test("github") => "fab fa-github"
  | _unknownUrl => "fas fa-users"
  }

let showSocialLinks = socialLinks =>
  <div
    className="inline-flex flex-wrap justify-center text-lg text-gray-800 mt-3 bg-gray-50 px-2 rounded-lg">
    {socialLinks
    |> Array.mapi((index, link) =>
      <a
        className="px-2 py-1 inline-block hover:text-primary-500"
        key={index |> string_of_int}
        target="_blank"
        href=link>
        <i className={socialLinkIconClass(link)} />
      </a>
    )
    |> React.array}
  </div>

let setSelectedTab = (selectedTab, setState) => setState(state => {...state, selectedTab})

let addNote = (setState, studentDetails, onAddCoachNotesCB, note) => {
  onAddCoachNotesCB()

  setState(state => {
    ...state,
    studentData: Loaded(StudentDetails.addNewNote(note, studentDetails)),
  })
}

let removeNote = (setState, studentDetails, noteId) =>
  setState(state => {
    ...state,
    studentData: Loaded(StudentDetails.removeNote(noteId, studentDetails)),
  })

let userInfo = (~key, ~avatarUrl, ~name, ~fulltitle) =>
  <div key className="shadow rounded-lg p-4 flex items-center mt-2">
    {CoursesStudents__PersonalCoaches.avatar(avatarUrl, name)}
    <div className="ms-2 md:ms-3">
      <div className="text-sm font-semibold"> {name |> str} </div>
      <div className="text-xs"> {fulltitle |> str} </div>
    </div>
  </div>

let coachInfo = studentDetails => {
  let coaches = studentDetails->StudentDetails.student->StudentInfo.personalCoaches
  coaches |> ArrayUtils.isNotEmpty
    ? <div className="mb-8">
        <h6 className="font-semibold"> {t("personal_coaches") |> str} </h6>
        {coaches
        |> Array.map(coach =>
          userInfo(
            ~key=coach |> Coach.userId,
            ~avatarUrl=coach |> Coach.avatarUrl,
            ~name=coach |> Coach.name,
            ~fulltitle=coach |> Coach.fullTitle,
          )
        )
        |> React.array}
      </div>
    : React.null
}

let navigateToStudent = (setState, _event) => setState(_ => initialState)

let otherTeamMembers = (setState, studentId, studentDetails) =>
  switch studentDetails->StudentDetails.team {
  | Some(team) =>
    <div className="block mt-8">
      <h6 className="font-semibold"> {t("other_team_members") |> str} </h6>
      {team
      ->StudentDetails.students
      ->Js.Array2.filter(student => StudentInfo.id(student) != studentId)
      ->Js.Array2.map(student => {
        let path = "/students/" ++ (student->StudentInfo.id ++ "/report")

        <Link
          className="block mt-2 rounded-lg border border-transparent hover:bg-primary-50 hover:border-primary-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500 transition"
          href=path
          onClick={navigateToStudent(setState)}
          key={student->StudentInfo.id}>
          {userInfo(
            ~key=student->StudentInfo.id,
            ~avatarUrl=student->StudentInfo.user->UserDetails.avatarUrl,
            ~name=student->StudentInfo.user->UserDetails.name,
            ~fulltitle=student->StudentInfo.user->UserDetails.fullTitle,
          )}
        </Link>
      }) |> React.array}
    </div>
  | None => React.null
  }

let inactiveWarning = student => {
  let warning = switch (
    student->StudentInfo.droppedOutAt,
    Cohort.endsAt(StudentInfo.cohort(student)),
  ) {
  | (Some(droppedOutAt), _) =>
    Some(
      t(
        ~variables=[("date", droppedOutAt->DateFns.formatPreset(~short=true, ~year=true, ()))],
        "dropped_out_at",
      ),
    )
  | (None, Some(endsAt)) =>
    endsAt->DateFns.isPast
      ? Some(
          t(
            ~variables=[("date", endsAt->DateFns.formatPreset(~short=true, ~year=true, ()))],
            "access_ended_at",
          ),
        )
      : None
  | (None, None) => None
  }

  warning |> OptionUtils.mapWithDefault(warning =>
    <div className="border border-yellow-400 rounded bg-yellow-400 py-2 px-3 mt-3">
      <i className="fas fa-exclamation-triangle" />
      <span className="ms-2"> {warning |> str} </span>
    </div>
  , React.null)
}

let onAddCoachNotesCB = (studentId, setState, _) => {
  getStudentDetails(studentId, setState)
}

let ids = student => {
  <div className="text-center mt-1">
    <ClickToCopy
      copy={StudentInfo.user(student)->UserDetails.id}
      className="inline-block hover:text-primary-500">
      <span className="text-xs"> {"User ID "->str} </span>
      <span className="font-semibold text-sm underline text-primary-500">
        {`#${StudentInfo.user(student)->UserDetails.id}`->str}
      </span>
    </ClickToCopy>
    <ClickToCopy
      copy={StudentInfo.id(student)} className="ms-2 inline-block hover:text-primary-500">
      <span className="text-xs"> {"Student ID "->str} </span>
      <span className="font-semibold text-sm underline text-primary-500">
        {`#${StudentInfo.id(student)}`->str}
      </span>
    </ClickToCopy>
    <p>
      {ts("cohort")->str}
      <em className="ms-1 font-semibold text-sm text-primary-500">
        {Cohort.name(student.cohort)->str}
      </em>
    </p>
  </div>
}

@react.component
let make = (~studentId, ~userId) => {
  let (state, setState) = React.useState(() => initialState)

  React.useEffect0(() => {
    ScrollLock.activate()
    Some(() => ScrollLock.deactivate())
  })

  React.useEffect1(() => {
    getStudentDetails(studentId, setState)
    None
  }, [studentId])

  <div
    className="fixed z-30 top-0 start-0 w-full h-full overflow-y-scroll md:overflow-hidden bg-white">
    {switch state.studentData {
    | Loaded(studentDetails) => {
        let student = studentDetails->StudentDetails.student
        <div className="flex flex-col md:flex-row md:h-screen">
          <div
            className="w-full md:w-2/5 bg-white p-4 md:p-8 md:py-6 2xl:px-16 2xl:py-12 md:overflow-y-auto">
            <div className="student-overlay__student-details relative pb-8">
              <a
                ariaLabel={t("close_student_report")}
                title={t("close_student_report")}
                href={closeOverlayLink(student)}
                className="absolute z-50 start-0 cursor-pointer top-0 inline-flex p-1 rounded-full bg-gray-50 h-10 w-10 justify-center items-center text-gray-600 hover:text-gray-900 hover:bg-gray-300 focus:outline-none focus:text-gray-900 focus:bg-gray-300 focus:ring-2 focus:ring-inset focus:ring-focusColor-500">
                <Icon className="if i-times-regular text-xl lg:text-2xl" />
              </a>
              <div
                className="student-overlay__student-avatar mx-auto w-18 h-18 md:w-24 md:h-24 text-xs border border-yellow-500 rounded-full overflow-hidden shrink-0">
                {switch student->StudentInfo.user->UserDetails.avatarUrl {
                | Some(avatarUrl) => <img className="w-full object-cover" src=avatarUrl />
                | None =>
                  <Avatar
                    name={student->StudentInfo.user->UserDetails.name} className="object-cover"
                  />
                }}
              </div>
              <h2 className="text-lg text-center mt-3">
                {student->StudentInfo.user->UserDetails.name |> str}
              </h2>
              <p className="text-sm font-semibold text-center mt-1">
                {student->StudentInfo.user->UserDetails.fullTitle |> str}
              </p>
              {ids(student)}
              {inactiveWarning(student)}
            </div>
            <div className="mt-8">
              <h6 className="font-semibold"> {t("targets_overview") |> str} </h6>
              <div className="flex -mx-2 flex-wrap mt-2">
                {targetsCompletionStatus(
                  studentDetails |> StudentDetails.targetsCompleted,
                  studentDetails |> StudentDetails.totalTargets,
                )}
                {quizPerformanceChart(
                  studentDetails |> StudentDetails.averageQuizScore,
                  studentDetails |> StudentDetails.quizzesAttempted,
                )}
              </div>
            </div>
            {studentDetails |> StudentDetails.averageGrades |> ArrayUtils.isNotEmpty
              ? <div className="mt-8">
                  <h6 className="font-semibold"> {t("average_grades") |> str} </h6>
                  <div className="flex -mx-2 flex-wrap">
                    {averageGradeCharts(
                      studentDetails |> StudentDetails.evaluationCriteria,
                      studentDetails |> StudentDetails.averageGrades,
                    )}
                  </div>
                </div>
              : React.null}
            {coachInfo(studentDetails)}
            {otherTeamMembers(setState, studentId, studentDetails)}
            <div className="mt-4">
              <div className="justify-between mt-8 flex space-x-2">
                <p className="text-sm font-semibold"> {t("milestone_targets")->str} </p>
                {milestoneTargetsCompletionStats(studentDetails)}
              </div>
              <div className="space-y-2">
                {ArrayUtils.copyAndSort(
                  (a, b) =>
                    a->CoursesStudents__MilestoneTargetsCompletionStatus.milestoneNumber -
                      b->CoursesStudents__MilestoneTargetsCompletionStatus.milestoneNumber,
                  StudentDetails.milestoneTargetsCompletionStatus(studentDetails),
                )
                ->Js.Array2.map(data => {
                  <Spread
                    props={
                      "data-milestone-id": data->CoursesStudents__MilestoneTargetsCompletionStatus.id,
                    }>
                    <div
                      className="flex gap-2 mt-2 items-center p-2 rounded-md border bg-gray-100 transition">
                      <div>
                        <span
                          className={"text-xs font-medium " ++ {
                            data->CoursesStudents__MilestoneTargetsCompletionStatus.completed
                              ? "text-green-700 bg-green-100 px-1 py-0.5 rounded"
                              : "text-orange-700 bg-orange-100 px-1 py-0.5 rounded"
                          }}>
                          {<Icon
                            className={data->CoursesStudents__MilestoneTargetsCompletionStatus.completed
                              ? "if i-check-circle-solid text-green-600"
                              : "if i-dashed-circle-light text-orange-600"}
                          />}
                        </span>
                      </div>
                      <div>
                        <p className="text-sm font-semibold">
                          {(ts("m") ++
                          string_of_int(
                            CoursesStudents__MilestoneTargetsCompletionStatus.milestoneNumber(data),
                          ))->str}
                        </p>
                      </div>
                      <div className="flex-1 text-sm truncate">
                        {data->CoursesStudents__MilestoneTargetsCompletionStatus.title->str}
                      </div>
                    </div>
                  </Spread>
                })
                ->React.array}
              </div>
            </div>
          </div>
          <div
            className="w-full relative md:w-3/5 bg-gray-50 md:border-s pb-20 md:pb-10 overflow-y-auto">
            <div
              className="sticky top-0 bg-gray-50 pt-2 md:pt-4 px-4 md:px-8 2xl:px-16 2xl:pt-10 z-30">
              <ul
                role="tablist"
                className="flex flex-1 md:flex-none p-1 md:p-0 space-x-1 md:space-x-0 text-center rounded-lg justify-between md:justify-start bg-gray-300 md:bg-transparent">
                <li
                  tabIndex=0
                  role="tab"
                  ariaSelected={state.selectedTab === Notes}
                  onClick={_event => setSelectedTab(Notes, setState)}
                  className={"cursor-pointer flex flex-1 justify-center md:flex-none rounded-md p-1.5 md:px-4 md:hover:bg-gray-50 md:py-2 text-sm font-semibold text-gray-800 hover:text-primary-600 hover:bg-gray-50 focus:outline-none focus:ring-inset focus:ring-2 focus:bg-gray-50 focus:ring-focusColor-500 md:focus:border-b-none md:focus:rounded-t-md " ++
                  switch state.selectedTab {
                  | Notes => "bg-white shadow md:shadow-none rounded-md md:rounded-none md:bg-transparent md:border-b-3 hover:bg-white md:hover:bg-transparent text-primary-500 md:border-primary-500 "
                  | Submissions => " "
                  }}>
                  {t("notes") |> str}
                </li>
                <li
                  tabIndex=0
                  role="tab"
                  ariaSelected={state.selectedTab === Submissions}
                  onClick={_event => setSelectedTab(Submissions, setState)}
                  className={"cursor-pointer flex flex-1 justify-center md:flex-none rounded-md p-1.5 md:px-4 md:hover:bg-gray-50 md:py-2 text-sm font-semibold text-gray-800 hover:text-primary-600 hover:bg-gray-50 focus:outline-none focus:ring-inset focus:ring-2 focus:bg-gray-50 focus:ring-focusColor-500 md:focus:border-b-none md:focus:rounded-t-md  " ++
                  switch state.selectedTab {
                  | Submissions => "bg-white shadow md:shadow-none rounded-md md:rounded-none md:bg-transparent md:border-b-3 hover:bg-white md:hover:bg-transparent text-primary-500 md:border-primary-500 "
                  | Notes => " "
                  }}>
                  {t("submissions") |> str}
                </li>
              </ul>
            </div>
            <div className="pt-2 px-4 md:px-8 2xl:px-16">
              {switch state.selectedTab {
              | Notes =>
                <CoursesStudents__CoachNotes
                  studentId
                  hasArchivedNotes={studentDetails->StudentDetails.hasArchivedNotes}
                  canModifyCoachNotes={studentDetails->StudentDetails.canModifyCoachNotes}
                  coachNotes={studentDetails->StudentDetails.coachNotes}
                  addNoteCB={addNote(
                    setState,
                    studentDetails,
                    onAddCoachNotesCB(studentId, setState),
                  )}
                  userId
                  removeNoteCB={removeNote(setState, studentDetails)}
                />
              | Submissions =>
                <CoursesStudents__SubmissionsList
                  studentId
                  submissions=state.submissions
                  updateSubmissionsCB={updateSubmissions(setState)}
                />
              }}
            </div>
          </div>
        </div>
      }

    | Loading =>
      <div className="flex flex-col md:flex-row md:h-screen">
        <div className="w-full md:w-2/5 bg-white p-4 md:p-8 2xl:p-16">
          {SkeletonLoading.image()}
          {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.userDetails())}
        </div>
        <div className="w-full relative md:w-3/5 bg-gray-50 md:border-s p-4 md:p-8 2xl:p-16">
          {SkeletonLoading.contents()}
          {SkeletonLoading.userDetails()}
        </div>
      </div>
    }}
  </div>
}
