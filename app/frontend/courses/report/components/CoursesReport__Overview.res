%%raw(`import "./CoursesReport__Overview.css"`)

open CoursesReport__Types
let str = React.string
let t = I18n.t(~scope="components.CoursesReport__Overview")
let ts = I18n.t(~scope="shared")

let avatar = (avatarUrl, name) => {
  let avatarClasses = "w-8 h-8 md:w-10 md:h-10 text-xs border border-gray-300 rounded-full overflow-hidden shrink-0 object-cover"
  switch avatarUrl {
  | Some(avatarUrl) => <img className=avatarClasses src=avatarUrl />
  | None => <Avatar name className=avatarClasses />
  }
}

let userInfo = (~key, ~avatarUrl, ~name, ~title) =>
  <div key className="w-full md:w-1/2 shadow rounded-lg p-4 flex items-center mt-2 bg-white">
    {CoursesStudents__PersonalCoaches.avatar(avatarUrl, name)}
    <div className="ms-2 md:ms-3">
      <div className="text-sm font-semibold"> {name |> str} </div>
      <div className="text-xs"> {title |> str} </div>
    </div>
  </div>

let coachInfo = coaches =>
  coaches |> ArrayUtils.isNotEmpty
    ? <div className="mt-8">
        <p className="text-sm font-semibold"> {t("personal_coaches") |> str} </p>
        {coaches
        |> Array.mapi((index, coach) =>
          userInfo(
            ~key=string_of_int(index),
            ~avatarUrl=coach |> Coach.avatarUrl,
            ~name=coach |> Coach.name,
            ~title=coach |> Coach.title,
          )
        )
        |> React.array}
      </div>
    : React.null

let doughnutChart = (color, percentage) =>
  <svg viewBox="0 0 36 36" className={"courses-report-overview__doughnut-chart " ++ color}>
    <path
      className="courses-report-overview__doughnut-chart-bg"
      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
    />
    <path
      className="courses-report-overview__doughnut-chart-stroke"
      strokeDasharray={percentage ++ ", 100"}
      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
    />
    <text x="50%" y="58%" className="courses-report-overview__doughnut-chart-text font-semibold">
      {percentage ++ "%" |> str}
    </text>
  </svg>

let targetsCompletionStatus = overview => {
  let targetsCompleted = overview |> StudentOverview.targetsCompleted
  let totalTargets = overview |> StudentOverview.totalTargets
  let targetsPendingReview = overview |> StudentOverview.targetsPendingReview
  let incompleteTargets =
    int_of_float(totalTargets) - int_of_float(targetsCompleted) - targetsPendingReview
  let targetCompletionPercent =
    targetsCompleted /. totalTargets *. 100.0 |> int_of_float |> string_of_int
  <div ariaLabel="target-completion-status" className="w-full lg:w-1/2 px-2">
    <div className="courses-report-overview__doughnut-chart-container bg-white flex items-center">
      <div> {doughnutChart("purple", targetCompletionPercent)} </div>
      <div className="ms-4">
        <p className="text-sm text-gray-600 font-semibold mt-1">
          {t(
            ~variables=[("targetsCount", string_of_int(incompleteTargets))],
            "incomplete_targets",
          ) |> str}
        </p>
        <p className="text-sm text-gray-600 font-semibold mt-1">
          {t(
            ~variables=[("targetsCount", string_of_int(targetsPendingReview))],
            "targets_pending_review",
          ) |> str}
        </p>
        <p className="text-sm text-gray-600 font-semibold mt-1">
          {t(
            ~variables=[("targetsCount", string_of_int(int_of_float(targetsCompleted)))],
            "targets_completed",
          ) |> str}
        </p>
      </div>
    </div>
  </div>
}

let quizPerformanceChart = (averageQuizScore, quizzesAttempted) =>
  switch averageQuizScore {
  | Some(score) =>
    <div ariaLabel="quiz-performance-chart" className="w-full lg:w-1/2 px-2 mt-2 lg:mt-0">
      <div className="courses-report-overview__doughnut-chart-container bg-white">
        <div> {doughnutChart("pink", score |> int_of_float |> string_of_int)} </div>
        <div className="ms-4">
          <p className="text-sm font-semibold mt-3"> {t("average_quiz_score") |> str} </p>
          <p className="text-sm text-gray-600 font-semibold leading-tight mt-1">
            {t(~count=quizzesAttempted, "quizzes_attempted")->str}
          </p>
        </div>
      </div>
    </div>
  | None => React.null
  }

let milestoneTargetsCompletionStatus = overview => {
  let milestoneTargets = overview->StudentOverview.milestoneTargetsCompletionStatus

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
  evaluationCriteria: array<CoursesReport__EvaluationCriterion.t>,
  averageGrades: array<StudentOverview.averageGrade>,
) =>
  averageGrades
  |> Array.map(grade => {
    let criterion = StudentOverview.evaluationCriterionForGrade(grade, evaluationCriteria)
    let passGrade = criterion |> CoursesReport__EvaluationCriterion.passGrade |> float_of_int
    let averageGrade = grade |> StudentOverview.gradeValue
    <div
      ariaLabel={"average-grade-for-criterion-" ++
      (criterion |> CoursesReport__EvaluationCriterion.id)}
      key={criterion |> CoursesReport__EvaluationCriterion.id}
      className="flex w-full lg:w-1/3 px-2 mt-2">
      <div className="courses-report-overview__pie-chart-container">
        <div className="flex px-5 pt-4 text-center items-center">
          <svg
            className={"courses-report-overview__pie-chart " ++ (
              averageGrade < passGrade
                ? "courses-report-overview__pie-chart--fail"
                : "courses-report-overview__pie-chart--pass"
            )}
            viewBox="0 0 32 32">
            <circle
              className={"courses-report-overview__pie-chart-circle " ++ (
                averageGrade < passGrade
                  ? "courses-report-overview__pie-chart-circle--fail"
                  : "courses-report-overview__pie-chart-circle--pass"
              )}
              strokeDasharray={StudentOverview.gradeAsPercentage(grade, criterion) ++ ", 100"}
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
          {criterion |> CoursesReport__EvaluationCriterion.name |> str}
        </p>
      </div>
    </div>
  })
  |> React.array

@react.component
let make = (~overviewData, ~coaches) =>
  <div className="max-w-3xl mx-auto">
    {switch overviewData {
    | OverviewData.Loaded(overview) =>
      <div className="flex flex-col">
        <div className="w-full">
          <div className="mt-8">
            <h6 className="text-sm font-semibold"> {ts("cohort")->str} </h6>
            <div
              className="max-w-auto shadow rounded-lg p-4 items-center mt-2 bg-white flex shrink gap-2">
              <div>
                <PfIcon className="if i-users-light font-normal text-lg" />
              </div>
              <p className="text-sm font-semibold break-all">
                {overview->StudentOverview.cohortName->str}
              </p>
            </div>
          </div>
          <div className="mt-8">
            <p className="text-sm font-semibold"> {t("targets_overview") |> str} </p>
            <div className="flex -mx-2 flex-wrap mt-2">
              {targetsCompletionStatus(overview)}
              {quizPerformanceChart(
                overview |> StudentOverview.averageQuizScore,
                overview |> StudentOverview.quizzesAttempted,
              )}
            </div>
          </div>
          {overview |> StudentOverview.averageGrades |> ArrayUtils.isNotEmpty
            ? <div className="mt-8">
                <h6 className="text-sm font-semibold"> {t("average_grades") |> str} </h6>
                <div className="flex -mx-2 flex-wrap">
                  {averageGradeCharts(
                    overview |> StudentOverview.evaluationCriteria,
                    overview |> StudentOverview.averageGrades,
                  )}
                </div>
              </div>
            : React.null}
          {coachInfo(coaches)}
          <div>
            <div className="flex justify-between mt-8">
              <p className="text-sm font-semibold">
                <span> {t("milestone_status_title")->str} </span>
                <HelpIcon
                  className="ml-2" responsiveAlignment=HelpIcon.Responsive(AlignLeft, AlignCenter)>
                  {t("milestone_status_help")->str}
                </HelpIcon>
              </p>
              {milestoneTargetsCompletionStatus(overview)}
            </div>
            <div className="grid gap-2 mt-2">
              {ArrayUtils.copyAndSort(
                (a, b) =>
                  a->CoursesReport__MilestoneTargetCompletionStatus.milestoneNumber -
                    b->CoursesReport__MilestoneTargetCompletionStatus.milestoneNumber,
                StudentOverview.milestoneTargetsCompletionStatus(overview),
              )
              ->Js.Array2.map(data => {
                <a
                  href={"/targets/" ++ CoursesReport__MilestoneTargetCompletionStatus.id(data)}
                  className="flex gap-2 items-center justify-between p-2 rounded-md border bg-gray-100 hover:bg-primary-100 hover:border-primary-500 hover:text-primary-500 transition">
                  <div className="flex items-center gap-2">
                    <p className="text-sm font-semibold">
                      {(ts("m") ++
                      string_of_int(
                        CoursesReport__MilestoneTargetCompletionStatus.milestoneNumber(data),
                      ))->str}
                    </p>
                    <p
                      className="max-w-[16ch] sm:max-w-[40ch] md:max-w-[32ch] lg:max-w-[56ch] 2xl:max-w-[64ch] truncate text-sm">
                      {data->CoursesReport__MilestoneTargetCompletionStatus.title->str}
                    </p>
                  </div>
                  <div className="flex-shrink-0">
                    <span
                      className={"text-xs font-medium " ++ {
                        data->CoursesReport__MilestoneTargetCompletionStatus.completed
                          ? "text-green-700 bg-green-100 px-1 py-0.5 rounded"
                          : "text-orange-700 bg-orange-100 px-1 py-0.5 rounded"
                      }}>
                      {<Icon
                        className={data->CoursesReport__MilestoneTargetCompletionStatus.completed
                          ? "if i-check-circle-solid text-green-600"
                          : "if i-dashed-circle-light text-orange-600"}
                      />}
                      {data->CoursesReport__MilestoneTargetCompletionStatus.completed
                        ? <span className="ms-1"> {t("milestone_completed") |> str} </span>
                        : <span className="ms-1"> {t("milestone_pending") |> str} </span>}
                    </span>
                  </div>
                </a>
              })
              ->React.array}
            </div>
          </div>
        </div>
      </div>
    | Unloaded =>
      <div className="flex flex-col">
        <div className="w-full bg-white p-8">
          {SkeletonLoading.heading()}
          {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.paragraph())}
          {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.userDetails())}
        </div>
      </div>
    }}
  </div>
