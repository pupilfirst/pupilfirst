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
  canModifyCoachNotes: bool,
  evaluationCriteria: array<CoursesStudents__EvaluationCriterion.t>,
  totalTargets: int,
  targetsCompleted: int,
  quizScores: array<string>,
  averageGrades: array<averageGrade>,
  student: CoursesStudents__StudentInfo.t,
  team: option<team>,
  milestoneTargetsCompletionStatus: array<CoursesStudents__MilestoneTargetsCompletionStatus.t>,
  courseId: string,
}

let student = t => t.student

let team = t => t.team

let students = team => team.students

let coachNotes = t => t.coachNotes

let hasArchivedNotes = t => t.hasArchivedNotes

let canModifyCoachNotes = t => t.canModifyCoachNotes

let courseId = t => t.courseId

let makeAverageGrade = (~evaluationCriterionId, ~grade) => {
  evaluationCriterionId: evaluationCriterionId,
  grade: grade,
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

let gradeValue = averageGrade => averageGrade.grade

let milestoneTargetsCompletionStatus = t => t.milestoneTargetsCompletionStatus

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

let makeTeam = (~id, ~name, ~students) => {id: id, name: name, students: students}

let make = (
  ~id,
  ~coachNotes,
  ~hasArchivedNotes,
  ~canModifyCoachNotes,
  ~evaluationCriteria,
  ~totalTargets,
  ~targetsCompleted,
  ~quizScores,
  ~averageGrades,
  ~student,
  ~team,
  ~courseId,
  ~milestoneTargetsCompletionStatus,
) => {
  id: id,
  coachNotes: coachNotes,
  hasArchivedNotes: hasArchivedNotes,
  canModifyCoachNotes: canModifyCoachNotes,
  evaluationCriteria: evaluationCriteria,
  totalTargets: totalTargets,
  targetsCompleted: targetsCompleted,
  quizScores: quizScores,
  averageGrades: averageGrades,
  student: student,
  team: team,
  courseId: courseId,
  milestoneTargetsCompletionStatus: milestoneTargetsCompletionStatus,
}
