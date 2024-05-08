type averageGrade = {
  evaluationCriterionId: string,
  grade: float,
}

type t = {
  id: string,
  cohortName: string,
  evaluationCriteria: array<CoursesReport__EvaluationCriterion.t>,
  totalPageReads: int,
  totalTargets: int,
  assignmentsPendingReview: int,
  assignmentsCompleted: int,
  totalAssignments: int,
  quizScores: array<string>,
  averageGrades: array<averageGrade>,
  milestonesCompletionStatus: array<CoursesReport__MilestoneCompletionStatus.t>,
}

let id = t => t.id

let cohortName = t => t.cohortName

let evaluationCriteria = t => t.evaluationCriteria

let totalPageReads = t => t.totalPageReads->float_of_int

let totalTargets = t => t.totalTargets->float_of_int

let assignmentsPendingReview = t => t.assignmentsPendingReview

let assignmentsCompleted = t => t.assignmentsCompleted->float_of_int

let totalAssignments = t => t.totalAssignments->float_of_int

let quizzesAttempted = t => t.quizScores->Array.length

let quizScores = t => t.quizScores
let averageGrades = t => t.averageGrades

let makeAverageGrade = (~evaluationCriterionId, ~grade) => {
  evaluationCriterionId,
  grade,
}

let milestonesCompletionStatus = t => t.milestonesCompletionStatus

let evaluationCriterionForGrade = (grade, evaluationCriteria) =>
  ArrayUtils.unsafeFind(
    ec => CoursesReport__EvaluationCriterion.id(ec) == grade.evaluationCriterionId,
    "Unable to find evaluation criterion with id: " ++
    (grade.evaluationCriterionId ++
    (" in component: " ++ "CoursesReport__Overview")),
    evaluationCriteria,
  )

let gradeValue = averageGrade => averageGrade.grade

let gradeAsPercentage = (
  averageGrade: averageGrade,
  evaluationCriterion: CoursesReport__EvaluationCriterion.t,
) => {
  let maxGrade = evaluationCriterion.maxGrade->float_of_int
  (averageGrade.grade /. maxGrade *. 100.0)->int_of_float->string_of_int
}

let computeAverageQuizScore = quizScores => {
  let sumOfPercentageScores =
    quizScores
    ->Js.Array2.map(quizScore => {
      let fractionArray = String.split_on_char('/', quizScore)->Array.of_list
      let (numerator, denominator) = (
        fractionArray[0]->float_of_string,
        fractionArray[1]->float_of_string,
      )
      numerator /. denominator *. 100.0
    })
    ->Js.Array2.reduce((a, b) => a +. b, 0.0)
  sumOfPercentageScores /. quizScores->Array.length->float_of_int
}

let averageQuizScore = t =>
  t.quizScores->ArrayUtils.isEmpty ? None : Some(computeAverageQuizScore(t.quizScores))

let make = (
  ~id,
  ~cohortName,
  ~evaluationCriteria,
  ~totalPageReads,
  ~totalTargets,
  ~assignmentsCompleted,
  ~totalAssignments,
  ~quizScores,
  ~averageGrades,
  ~assignmentsPendingReview,
  ~milestonesCompletionStatus,
) => {
  id,
  cohortName,
  evaluationCriteria,
  totalPageReads,
  totalTargets,
  assignmentsCompleted,
  totalAssignments,
  quizScores,
  averageGrades,
  assignmentsPendingReview,
  milestonesCompletionStatus,
}
