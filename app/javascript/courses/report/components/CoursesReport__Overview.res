%bs.raw(`require("./CoursesReport__Overview.css")`)

open CoursesReport__Types
let str = React.string
let t = I18n.t(~scope="components.CoursesReport__Overview")

let avatar = (avatarUrl, name) => {
  let avatarClasses = "w-8 h-8 md:w-10 md:h-10 text-xs border border-gray-400 rounded-full overflow-hidden flex-shrink-0 object-cover"
  switch avatarUrl {
  | Some(avatarUrl) => <img className=avatarClasses src=avatarUrl />
  | None => <Avatar name className=avatarClasses />
  }
}

let userInfo = (~key, ~avatarUrl, ~name, ~title) =>
  <div key className="w-full md:w-1/2 shadow rounded-lg p-4 flex items-center mt-2 bg-white">
    {CoursesStudents__TeamCoaches.avatar(avatarUrl, name)}
    <div className="ml-2 md:ml-3">
      <div className="text-sm font-semibold"> {name |> str} </div>
      <div className="text-xs"> {title |> str} </div>
    </div>
  </div>

let coachInfo = coaches =>
  coaches |> ArrayUtils.isNotEmpty
    ? <div className="mb-8">
        <h6 className="font-semibold"> {t("personal_coaches") |> str} </h6>
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
      <div className="ml-4">
        <p className="text-sm text-gray-700 font-semibold mt-1">
          {t(
            ~variables=[("targetsCount", string_of_int(incompleteTargets))],
            "incomplete_targets",
          ) |> str}
        </p>
        <p className="text-sm text-gray-700 font-semibold mt-1">
          {t(
            ~variables=[("targetsCount", string_of_int(targetsPendingReview))],
            "targets_pending_review",
          ) |> str}
        </p>
        <p className="text-sm text-gray-700 font-semibold mt-1">
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
        <div className="ml-4">
          <p className="text-sm font-semibold mt-3"> {t("average_quiz_score") |> str} </p>
          <p className="text-sm text-gray-700 font-semibold leading-tight mt-1">
            {Inflector.pluralize(t("quiz"), ~count=quizzesAttempted, ~inclusive=true, ()) ++
            t("attempted") |> str}
          </p>
        </div>
      </div>
    </div>
  | None => React.null
  }

let averageGradeCharts = (
  evaluationCriteria: array<CoursesReport__EvaluationCriterion.t>,
  averageGrades: array<StudentOverview.averageGrade>,
) => averageGrades |> Array.map(grade => {
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
          <span className="ml-3 text-lg font-semibold">
            {(grade.grade |> Js.Float.toString) ++ ("/" ++ (criterion.maxGrade |> string_of_int))
              |> str}
          </span>
        </div>
        <p className="text-sm font-semibold px-5 pt-3 pb-4">
          {criterion |> CoursesReport__EvaluationCriterion.name |> str}
        </p>
      </div>
    </div>
  }) |> React.array
let studentLevelClasses = (levelNumber, levelCompleted, currentLevelNumber) => {
  let reached =
    levelNumber <= currentLevelNumber ? "courses-report-overview__student-level--reached" : ""

  let current =
    levelNumber == currentLevelNumber ? " courses-report-overview__student-level--current" : ""

  let completed = levelCompleted ? " courses-report-overview__student-level--completed" : ""

  reached ++ (current ++ completed)
}

let levelProgressBar = (levelId, levels, levelsCompleted) => {
  let applicableLevels = levels |> Js.Array.filter(level => Level.number(level) != 0)

  let courseCompleted =
    applicableLevels |> Array.for_all(level => levelsCompleted |> Array.mem(level |> Level.id))

  let currentLevelNumber =
    applicableLevels
    |> ArrayUtils.unsafeFind(
      level => Level.id(level) == levelId,
      "Unable to find level with id" ++ (levelId ++ "in CoursesReport__Overview"),
    )
    |> Level.number

  <div className="mb-8">
    <div className="flex justify-between items-end">
      <h6 className="text-sm font-semibold"> {t("level_progress") |> str} </h6>
      {courseCompleted
        ? <p className="text-green-600 font-semibold">
            {`🎉` |> str} <span className="text-xs ml-px"> {t("course_completed") |> str} </span>
          </p>
        : React.null}
    </div>
    <div className="h-14 flex items-center shadow bg-white rounded-lg px-4 py-2 mt-1">
      <ul
        className={"courses-report-overview__student-level-progress flex w-full " ++ (
          courseCompleted ? "courses-report-overview__student-level-progress--completed" : ""
        )}>
        {applicableLevels |> Level.sort |> Array.map(level => {
          let levelNumber = level |> Level.number
          let levelCompleted = levelsCompleted |> Array.mem(level |> Level.id)

          <li
            key={level |> Level.id}
            className={"flex-1 courses-report-overview__student-level " ++
            studentLevelClasses(levelNumber, levelCompleted, currentLevelNumber)}>
            <span className="courses-report-overview__student-level-count">
              {levelNumber |> string_of_int |> str}
            </span>
          </li>
        }) |> React.array}
      </ul>
    </div>
  </div>
}

@react.component
let make = (~overviewData, ~levels, ~coaches) =>
  <div className="max-w-3xl mx-auto">
    {switch overviewData {
    | OverviewData.Loaded(overview) =>
      <div className="flex flex-col">
        <div className="w-full">
          {levelProgressBar(
            overview |> StudentOverview.levelId,
            levels,
            overview |> StudentOverview.completedLevelIds,
          )}
          <div className="mb-8">
            <h6 className="font-semibold"> {t("targets_overview") |> str} </h6>
            <div className="flex -mx-2 flex-wrap mt-2">
              {targetsCompletionStatus(overview)}
              {quizPerformanceChart(
                overview |> StudentOverview.averageQuizScore,
                overview |> StudentOverview.quizzesAttempted,
              )}
            </div>
          </div>
          {overview |> StudentOverview.averageGrades |> ArrayUtils.isNotEmpty
            ? <div className="mb-8">
                <h6 className="font-semibold"> {t("average_grades") |> str} </h6>
                <div className="flex -mx-2 flex-wrap">
                  {averageGradeCharts(
                    overview |> StudentOverview.evaluationCriteria,
                    overview |> StudentOverview.averageGrades,
                  )}
                </div>
              </div>
            : React.null}
          {coachInfo(coaches)}
        </div>
      </div>
    | Unloaded =>
      <div className="flex flex-col">
        <div className="w-full bg-white p-8">
          {SkeletonLoading.heading()}
          {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.paragraph())}
          {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.profileCard())}
        </div>
      </div>
    }}
  </div>
