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
          id, name, maxGrade
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
        totalPageReads
        assignmentsCompleted
        totalAssignments
        quizScores
        averageGrades {
          evaluationCriterionId
          averageGrade
        }
        milestonesCompletionStatus {
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
        )
      )

    let averageGrades =
      response.studentDetails.averageGrades->Js.Array2.map(gradeData =>
        StudentDetails.makeAverageGrade(
          ~evaluationCriterionId=gradeData.evaluationCriterionId,
          ~grade=gradeData.averageGrade,
        )
      )

    let milestonesCompletionStatus =
      response.studentDetails.milestonesCompletionStatus->Js.Array2.map(milestone =>
        CoursesStudents__MilestonesCompletionStatus.make(
          ~id=milestone.id,
          ~title=milestone.title,
          ~milestoneNumber=milestone.milestoneNumber,
          ~completed=milestone.completed,
        )
      )

    let studentDetails = StudentDetails.make(
      ~id=studentId,
      ~hasArchivedNotes=response.hasArchivedCoachNotes,
      ~canModifyCoachNotes=response.studentDetails.canModifyCoachNotes,
      ~coachNotes,
      ~evaluationCriteria,
      ~totalTargets=response.studentDetails.totalTargets,
      ~totalPageReads=response.studentDetails.totalPageReads,
      ~assignmentsCompleted=response.studentDetails.assignmentsCompleted,
      ~totalAssignments=response.studentDetails.totalAssignments,
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
      ~milestonesCompletionStatus,
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

let assignmentsCompletionStatus = (assignmentsCompleted, totalAssignments) => {
  let assignmentsCompletionPercent =
    (assignmentsCompleted /. totalAssignments *. 100.0)->int_of_float->string_of_int

  <div ariaLabel="assignments-completion-status" className="w-full lg:w-1/2 px-2">
    <div className="student-overlay__doughnut-chart-container bg-gray-50">
      {doughnutChart("purple", assignmentsCompletionPercent)}
      <p className="text-sm font-semibold text-center mt-3">
        {ts("total_assignments_completed")->str}
      </p>
      <p className="text-sm text-gray-600 font-semibold text-center mt-1">
        {ts(
          ~variables=[
            ("completed", assignmentsCompleted->int_of_float->string_of_int),
            ("total", totalAssignments->int_of_float->string_of_int),
          ],
          "assignments_completed",
        )->str}
      </p>
    </div>
  </div>
}

let pagesReadStatus = (totalPageReads, totalTargets) => {
  let totalPagesReadPercent = (totalPageReads /. totalTargets *. 100.0)->int_of_float->string_of_int

  <div ariaLabel="targets-read-status" className="w-full lg:w-1/2 px-2 mt-2 lg:mt-0">
    <div className="student-overlay__doughnut-chart-container bg-gray-50">
      {doughnutChart("purple", totalPagesReadPercent)}
      <p className="text-sm font-semibold text-center mt-3"> {ts("total_pages_read")->str} </p>
      <p className="text-sm text-gray-600 font-semibold text-center mt-1">
        {ts(
          ~variables=[
            ("read", totalPageReads->int_of_float->string_of_int),
            ("total", totalTargets->int_of_float->string_of_int),
          ],
          "pages_read",
        )->str}
      </p>
    </div>
  </div>
}

let quizPerformanceChart = (averageQuizScore, quizzesAttempted) =>
  switch averageQuizScore {
  | Some(score) =>
    <div ariaLabel="quiz-performance-chart" className="w-full lg:w-1/2 px-2 mt-2">
      <div className="student-overlay__doughnut-chart-container bg-gray-50">
        {doughnutChart("pink", score |> int_of_float |> string_of_int)}
        <p className="text-sm font-semibold text-center mt-3"> {t("average_quiz_score") |> str} </p>
        <p className="text-sm text-gray-600 font-semibold text-center leading-tight mt-1">
          {t(~count=quizzesAttempted, "quizzes_attempted")->str}
        </p>
      </div>
    </div>
  | None => React.null
  }

let milestonesCompletionStats = studentDetails => {
  let milestones = studentDetails->StudentDetails.milestonesCompletionStatus

  let totalMilestones = Js.Array2.length(milestones)

  let completedMilestones =
    milestones->Js.Array2.filter(target => target.completed == true)->Js.Array2.length

  let milestonesCompletionPercentage = string_of_int(
    int_of_float(float_of_int(completedMilestones) /. float_of_int(totalMilestones) *. 100.0),
  )

  <div className="flex items-center gap-2 flex-shrink-0">
    <p className="text-xs font-medium text-gray-500">
      {(completedMilestones->string_of_int ++ " / " ++ totalMilestones->string_of_int)->str}
      <span className="px-2 text-gray-300"> {"|"->str} </span>
      {ts("percentage_completed", ~variables=[("percentage", milestonesCompletionPercentage)])->str}
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
          strokeDasharray={milestonesCompletionPercentage ++ ", 100"}
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
    <div
      ariaLabel={"average-grade-for-criterion-" ++
      (criterion |> CoursesStudents__EvaluationCriterion.id)}
      key={criterion |> CoursesStudents__EvaluationCriterion.id}
      className="flex w-full lg:w-1/2 px-2 mt-2">
      <div className="student-overlay__pie-chart-container">
        <div className="flex px-5 pt-4 text-center items-center">
          <svg
            className="student-overlay__pie-chart student-overlay__pie-chart--pass"
            viewBox="0 0 32 32">
            <circle
              className="student-overlay__pie-chart-circle student-overlay__pie-chart-circle--pass"
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
            <div className="student-overlay__student-details pb-4">
              <div>
                <div className="flex items-center justify-start gap-2 flex-wrap">
                  <div>
                    <a
                      ariaLabel={t("close_student_report")}
                      title={t("close_student_report")}
                      href={closeOverlayLink(student)}
                      className="z-50 start-0 cursor-pointer top-0 inline-flex p-1 rounded-full bg-gray-50 h-11 w-11 justify-center items-center text-gray-600 hover:text-gray-900 hover:bg-gray-300 focus:outline-none focus:text-gray-900 focus:bg-gray-300 focus:ring-2 focus:ring-inset focus:ring-focusColor-500">
                      <Icon className="if i-arrow-left-light if-fw text-xl lg:text-2xl" />
                    </a>
                  </div>
                  <div>
                    <div
                      className="student-overlay__student-avatar mx-auto w-14 h-14 md:w-16 md:h-16 text-xs border border-yellow-500 rounded-full overflow-hidden shrink-0">
                      {switch student->StudentInfo.user->UserDetails.avatarUrl {
                      | Some(avatarUrl) => <img className="w-full object-cover" src=avatarUrl />
                      | None =>
                        <Avatar
                          name={student->StudentInfo.user->UserDetails.name}
                          className="object-cover"
                        />
                      }}
                    </div>
                  </div>
                  <div className="ps-1">
                    <div>
                      <h2 className="text-lg text-left font-semibold">
                        {student->StudentInfo.user->UserDetails.name->str}
                      </h2>
                    </div>
                    <div className="text-sm font-semibold">
                      {student->StudentInfo.user->UserDetails.title->str}
                    </div>
                  </div>
                </div>
                <div className="mt-4 space-y-1 flex flex-col">
                  <div className="flex flex-wrap items-center justify-normal gap-2">
                    <div className="flex">
                      <PfIcon className="if i-user-regular if-fw text-xl" />
                      <span className="text-gray-500 font-normal"> {t("user_id")->str} </span>
                      <ClickToCopy
                        copy={StudentInfo.user(student)->UserDetails.id}
                        className="inline-block hover:text-primary-500">
                        <span className="ms-2 text-base font-semibold">
                          {`#${StudentInfo.user(student)->UserDetails.id}`->str}
                        </span>
                      </ClickToCopy>
                    </div>
                    <div className="flex">
                      <PfIcon className="if i-academic-cap-light if-fw text-xl" />
                      <span className="text-gray-500 font-normal"> {t("student_id")->str} </span>
                      <ClickToCopy
                        copy={StudentInfo.id(student)}
                        className="inline-block hover:text-primary-500">
                        <span className="ms-2 text-base font-semibold">
                          {`#${StudentInfo.id(student)}`->str}
                        </span>
                      </ClickToCopy>
                    </div>
                  </div>
                  <div className="flex">
                    <PfIcon className="if i-users-light if-fw text-xl " />
                    <span className="text-gray-500 font-normal"> {ts("cohort")->str} </span>
                    <span className="ms-2 text-base font-semibold break-normal">
                      {student->StudentInfo.cohort->Cohort.name->str}
                    </span>
                  </div>
                  {switch student->StudentInfo.user->UserDetails.currentStandingName {
                  | Some(name) =>
                    <div className="flex">
                      <PfIcon className="if i-shield-light if-fw text-xl" />
                      <span className="text-gray-500 font-normal">
                        {ts("user_standing.standing")->str}
                      </span>
                      <span className="ms-2 text-base font-semibold"> {name->str} </span>
                    </div>
                  | None => React.null
                  }}
                  {switch student->StudentInfo.user->UserDetails.affiliation {
                  | Some(name) =>
                    <div className="space-x-1">
                      <PfIcon className="if i-school-light if-fw text-xl" />
                      <span className="text-gray-500 font-normal"> {t("affiliation")->str} </span>
                      <span className="ms-2 text-base font-semibold"> {name->str} </span>
                    </div>
                  | None => React.null
                  }}
                </div>
              </div>
              {inactiveWarning(student)}
            </div>
            <div className="mt-8">
              <h6 className="font-semibold"> {ts("targets_overview")->str} </h6>
              <div className="flex -mx-2 flex-wrap mt-2">
                {assignmentsCompletionStatus(
                  studentDetails->StudentDetails.assignmentsCompleted,
                  studentDetails->StudentDetails.totalAssignments,
                )}
                {pagesReadStatus(
                  studentDetails->StudentDetails.totalPageReads,
                  studentDetails->StudentDetails.totalTargets,
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
                <p className="text-sm font-semibold"> {ts("milestones")->str} </p>
                {milestonesCompletionStats(studentDetails)}
              </div>
              <div className="space-y-2">
                {ArrayUtils.copyAndSort(
                  (a, b) =>
                    a->CoursesStudents__MilestonesCompletionStatus.milestoneNumber -
                      b->CoursesStudents__MilestonesCompletionStatus.milestoneNumber,
                  StudentDetails.milestonesCompletionStatus(studentDetails),
                )
                ->Js.Array2.map(data => {
                  <Spread
                    props={
                      "data-milestone-id": data->CoursesStudents__MilestonesCompletionStatus.id,
                    }>
                    <div
                      className="flex gap-2 mt-2 items-center p-2 rounded-md border bg-gray-100 transition">
                      <div>
                        <span
                          className={"text-xs font-medium inline-flex items-center " ++ {
                            data->CoursesStudents__MilestonesCompletionStatus.completed
                              ? "text-green-700 bg-green-100 px-1 py-0.5 rounded"
                              : "text-orange-700 bg-orange-100 px-1 py-0.5 rounded"
                          }}>
                          {<Icon
                            className={data->CoursesStudents__MilestonesCompletionStatus.completed
                              ? "if i-check-circle-solid text-green-600"
                              : "if i-dashed-circle-light text-orange-600"}
                          />}
                        </span>
                      </div>
                      <div>
                        <p className="text-sm font-semibold">
                          {(ts("m") ++
                          string_of_int(
                            CoursesStudents__MilestonesCompletionStatus.milestoneNumber(data),
                          ))->str}
                        </p>
                      </div>
                      <div className="flex-1 text-sm truncate">
                        {data->CoursesStudents__MilestonesCompletionStatus.title->str}
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
