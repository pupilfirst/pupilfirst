type averageGrade = {
  evaluationCriterionId: string,
  grade: float,
}

type t = {
  id: string,
  cohortName: string,
  evaluationCriteria: array<CoursesReport__EvaluationCriterion.t>,
  totalTargets: int,
  targetsPendingReview: int,
  targetsCompleted: int,
  quizScores: array<string>,
  averageGrades: array<averageGrade>,
  milestoneTargetsCompletionStatus: array<CoursesReport__MilestoneTargetCompletionStatus.t>,
}

let id = t => t.id

let cohortName = t => t.cohortName

let evaluationCriteria = t => t.evaluationCriteria

let totalTargets = t => t.totalTargets->float_of_int

let targetsPendingReview = t => t.targetsPendingReview

let targetsCompleted = t => t.targetsCompleted->float_of_int

let quizzesAttempted = t => t.quizScores->Array.length

let quizScores = t => t.quizScores
let averageGrades = t => t.averageGrades

let makeAverageGrade = (~evaluationCriterionId, ~grade) => {
  evaluationCriterionId: evaluationCriterionId,
  grade: grade,
}

let milestoneTargetsCompletionStatus = t => t.milestoneTargetsCompletionStatus

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
  ~totalTargets,
  ~targetsCompleted,
  ~quizScores,
  ~averageGrades,
  ~targetsPendingReview,
  ~milestoneTargetsCompletionStatus,
) => {
  id: id,
  cohortName: cohortName,
  evaluationCriteria: evaluationCriteria,
  totalTargets: totalTargets,
  targetsCompleted: targetsCompleted,
  quizScores: quizScores,
  averageGrades: averageGrades,
  targetsPendingReview: targetsPendingReview,
  milestoneTargetsCompletionStatus: milestoneTargetsCompletionStatus,
}
