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
}

let student = t => t.student

let team = t => t.team

let students = team => team.students

let coachNotes = t => t.coachNotes

let hasArchivedNotes = t => t.hasArchivedNotes

let makeAverageGrade = gradesData =>
  gradesData |> Js.Array.map(gradeData => {
    evaluationCriterionId: gradeData["evaluationCriterionId"],
    grade: gradeData["averageGrade"],
  })

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

let makeTeam = (teamId, teamName, students) => {id: teamId, name: teamName, students: students}

let makeTeamFromJs = teamData => {
  makeTeam(
    teamData["id"],
    teamData["name"],
    teamData["students"]->Js.Array2.map(CoursesStudents__StudentInfo.makeFromJs),
  )
}

let makeFromJs = (id, studentDetails, coachNotes, hasArchivedNotes) => {
  id: id,
  coachNotes: coachNotes |> Js.Array.map(note => note |> CoursesStudents__CoachNote.makeFromJs),
  hasArchivedNotes: hasArchivedNotes,
  evaluationCriteria: studentDetails["evaluationCriteria"] |> CoursesStudents__EvaluationCriterion.makeFromJs,
  totalTargets: studentDetails["totalTargets"],
  targetsCompleted: studentDetails["targetsCompleted"],
  quizScores: studentDetails["quizScores"],
  averageGrades: studentDetails["averageGrades"] |> makeAverageGrade,
  completedLevelIds: studentDetails["completedLevelIds"],
  student: studentDetails["student"] |> CoursesStudents__StudentInfo.makeFromJs,
  team: studentDetails["team"]->Belt.Option.map(makeTeamFromJs),
}
