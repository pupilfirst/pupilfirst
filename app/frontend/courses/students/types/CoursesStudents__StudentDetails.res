type averageGrade = {
  evaluationCriterionId: string,
  grade: float,
}

type team = {
  id: string,
  name: string,
  students: array<CoursesStudents__StudentInfo.t>,
}

type t = {
  id: string,
  coachNotes: array<CoursesStudents__CoachNote.t>,
  hasArchivedNotes: bool,
  evaluationCriteria: array<CoursesStudents__EvaluationCriterion.t>,
  totalTargets: int,
  targetsCompleted: int,
  quizScores: array<string>,
  averageGrades: array<averageGrade>,
  completedLevelIds: array<string>,
  student: CoursesStudents__StudentInfo.t,
  team: option<team>,
  levels: array<Shared__Level.t>,
  courseId: string,
}

let student = t => t.student

let team = t => t.team

let students = team => team.students

let coachNotes = t => t.coachNotes

let hasArchivedNotes = t => t.hasArchivedNotes

let levels = t => t.levels

let courseId = t => t.courseId

let makeAverageGrade = (~evaluationCriterionId, ~grade) => {
  evaluationCriterionId,
  grade,
}

let totalTargets = t => t.totalTargets |> float_of_int

let gradeAsPercentage = (
  averageGrade: averageGrade,
  evaluationCriterion: CoursesStudents__EvaluationCriterion.t,
) => {
  let maxGrade = evaluationCriterion.maxGrade |> float_of_int
  averageGrade.grade /. maxGrade *. 100.0 |> int_of_float |> string_of_int
}

let targetsCompleted = t => t.targetsCompleted |> float_of_int

let quizzesAttempted = t => t.quizScores |> Array.length

let evaluationCriteria = t => t.evaluationCriteria

let averageGrades = t => t.averageGrades

let completedLevelIds = t => t.completedLevelIds

let gradeValue = averageGrade => averageGrade.grade

let evaluationCriterionForGrade = (grade, evaluationCriteria, componentName) =>
  evaluationCriteria |> ArrayUtils.unsafeFind(
    ec => CoursesStudents__EvaluationCriterion.id(ec) == grade.evaluationCriterionId,
    "Unable to find evaluation criterion with id: " ++
    (grade.evaluationCriterionId ++
    (" in component: " ++ componentName)),
  )

let addNewNote = (note, t) => {
  let notes = Array.append(t.coachNotes, [note])
  {...t, coachNotes: notes}
}

let removeNote = (noteId, t) => {
  let notes = t.coachNotes |> Js.Array.filter(note => CoursesStudents__CoachNote.id(note) != noteId)
  {...t, coachNotes: notes, hasArchivedNotes: true}
}

let computeAverageQuizScore = quizScores => {
  let sumOfPercentageScores =
    quizScores
    |> Array.map(quizScore => {
      let fractionArray = quizScore |> String.split_on_char('/') |> Array.of_list
      let (numerator, denominator) = (
        fractionArray[0] |> float_of_string,
        fractionArray[1] |> float_of_string,
      )
      numerator /. denominator *. 100.0
    })
    |> Js.Array.reduce((a, b) => a +. b, 0.0)
  sumOfPercentageScores /. (quizScores |> Array.length |> float_of_int)
}

let averageQuizScore = t =>
  t.quizScores |> ArrayUtils.isEmpty ? None : Some(computeAverageQuizScore(t.quizScores))

let makeTeam = (~id, ~name, ~students) => {id, name, students}

let make = (
  ~id,
  ~coachNotes,
  ~hasArchivedNotes,
  ~evaluationCriteria,
  ~totalTargets,
  ~targetsCompleted,
  ~quizScores,
  ~averageGrades,
  ~completedLevelIds,
  ~student,
  ~team,
  ~levels,
  ~courseId,
) => {
  id,
  coachNotes,
  hasArchivedNotes,
  evaluationCriteria,
  totalTargets,
  targetsCompleted,
  quizScores,
  averageGrades,
  completedLevelIds,
  student,
  team,
  levels,
  courseId,
}
