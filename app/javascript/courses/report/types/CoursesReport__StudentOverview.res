type averageGrade = {
  evaluationCriterionId: string,
  grade: float,
}

type t = {
  id: string,
  evaluationCriteria: array<CoursesReport__EvaluationCriterion.t>,
  levelId: string,
  totalTargets: int,
  targetsPendingReview: int,
  targetsCompleted: int,
  quizScores: array<string>,
  averageGrades: array<averageGrade>,
  completedLevelIds: array<string>,
}

let id = t => t.id
let levelId = t => t.levelId
let evaluationCriteria = t => t.evaluationCriteria

let totalTargets = t => t.totalTargets |> float_of_int

let targetsPendingReview = t => t.targetsPendingReview

let targetsCompleted = t => t.targetsCompleted |> float_of_int

let quizzesAttempted = t => t.quizScores |> Array.length

let quizScores = t => t.quizScores
let averageGrades = t => t.averageGrades

let completedLevelIds = t => t.completedLevelIds

let makeAverageGrade = gradesData => gradesData |> Js.Array.map(gradeData => {
    evaluationCriterionId: gradeData["evaluationCriterionId"],
    grade: gradeData["averageGrade"],
  })

let evaluationCriterionForGrade = (grade, evaluationCriteria) =>
  evaluationCriteria |> ArrayUtils.unsafeFind(
    ec => CoursesReport__EvaluationCriterion.id(ec) == grade.evaluationCriterionId,
    "Unable to find evaluation criterion with id: " ++
    (grade.evaluationCriterionId ++
    (" in component: " ++ "CoursesReport__Overview")),
  )

let gradeValue = averageGrade => averageGrade.grade

let gradeAsPercentage = (
  averageGrade: averageGrade,
  evaluationCriterion: CoursesReport__EvaluationCriterion.t,
) => {
  let maxGrade = evaluationCriterion.maxGrade |> float_of_int
  averageGrade.grade /. maxGrade *. 100.0 |> int_of_float |> string_of_int
}

let computeAverageQuizScore = quizScores => {
  let sumOfPercentageScores = quizScores |> Array.map(quizScore => {
    let fractionArray = quizScore |> String.split_on_char('/') |> Array.of_list
    let (numerator, denominator) = (
      fractionArray[0] |> float_of_string,
      fractionArray[1] |> float_of_string,
    )
    numerator /. denominator *. 100.0
  }) |> Js.Array.reduce((a, b) => a +. b, 0.0)
  sumOfPercentageScores /. (quizScores |> Array.length |> float_of_int)
}

let averageQuizScore = t =>
  t.quizScores |> ArrayUtils.isEmpty ? None : Some(computeAverageQuizScore(t.quizScores))

let makeFromJs = (id, studentData) => {
  id: id,
  evaluationCriteria: studentData["evaluationCriteria"] |> CoursesReport__EvaluationCriterion.makeFromJs,
  totalTargets: studentData["totalTargets"],
  levelId: studentData["team"]["levelId"],
  targetsCompleted: studentData["targetsCompleted"],
  quizScores: studentData["quizScores"],
  averageGrades: studentData["averageGrades"] |> makeAverageGrade,
  completedLevelIds: studentData["completedLevelIds"],
  targetsPendingReview: studentData["targetsPendingReview"],
}
