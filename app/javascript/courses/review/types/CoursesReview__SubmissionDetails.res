module OverlaySubmission = CoursesReview__OverlaySubmission
module IndexSubmission = CoursesReview__IndexSubmission
module Student = CoursesReview__Student
module ReviewChecklistItem = CoursesReview__ReviewChecklistItem
module SubmissionMeta = CoursesReview__SubmissionMeta
module Coach = UserProxy

type t = {
  submission: OverlaySubmission.t,
  allSubmissions: array<SubmissionMeta.t>,
  targetId: string,
  targetTitle: string,
  students: array<Student.t>,
  levelNumber: string,
  levelId: string,
  evaluationCriteria: array<EvaluationCriterion.t>,
  reviewChecklist: array<ReviewChecklistItem.t>,
  targetEvaluationCriteriaIds: array<string>,
  inactiveStudents: bool,
  coaches: array<Coach.t>,
  teamName: option<string>,
  courseId: string
}
let submission = t => t.submission
let allSubmissions = t=> t.allSubmissions
let targetId = t => t.targetId
let targetTitle = t => t.targetTitle
let levelNumber = t => t.levelNumber
let students = t => t.students
let evaluationCriteria = t => t.evaluationCriteria
let reviewChecklist = t => t.reviewChecklist
let targetEvaluationCriteriaIds = t => t.targetEvaluationCriteriaIds
let inactiveStudents = t => t.inactiveStudents
let coaches = t => t.coaches
let teamName = t => t.teamName
let courseId = t=> t.courseId

let make = (
  ~submission,
  ~allSubmissions,
  ~targetId,
  ~targetTitle,
  ~students,
  ~levelNumber,
  ~evaluationCriteria,
  ~levelId,
  ~reviewChecklist,
  ~targetEvaluationCriteriaIds,
  ~inactiveStudents,
  ~coaches,
  ~teamName,
  ~courseId
) => {
  submission: submission,
  allSubmissions: allSubmissions,
  targetId: targetId,
  targetTitle: targetTitle,
  students: students,
  levelNumber: levelNumber,
  evaluationCriteria: evaluationCriteria,
  levelId: levelId,
  reviewChecklist: reviewChecklist,
  targetEvaluationCriteriaIds: targetEvaluationCriteriaIds,
  inactiveStudents: inactiveStudents,
  coaches: coaches,
  teamName: teamName,
  courseId: courseId
}



let decodeJs = details =>
  make(
    ~submission=OverlaySubmission.makeFromJs(details["submission"]),
    ~allSubmissions=ArrayUtils.copyAndSort(
      (s1, s2) =>
        DateFns.differenceInSeconds(
          SubmissionMeta.createdAt(s2),
          SubmissionMeta.createdAt(s1),
        ),
      SubmissionMeta.makeFromJs(details["allSubmissions"]),
    ),
    ~targetId=details["targetId"],
    ~targetTitle=details["targetTitle"],
    ~students=details["students"] |> Array.map(Student.makeFromJs),
    ~levelNumber=details["levelNumber"],
    ~levelId=details["levelId"],
    ~targetEvaluationCriteriaIds=details["targetEvaluationCriteriaIds"],
    ~inactiveStudents=details["inactiveStudents"],
    ~evaluationCriteria=details["evaluationCriteria"] |> Js.Array.map(ec =>
      EvaluationCriterion.make(
        ~id=ec["id"],
        ~name=ec["name"],
        ~maxGrade=ec["maxGrade"],
        ~passGrade=ec["passGrade"],
        ~gradesAndLabels=ec["gradeLabels"] |> Array.map(gradeAndLabel =>
          GradeLabel.makeFromJs(gradeAndLabel)
        ),
      )
    ),
    ~reviewChecklist=details["reviewChecklist"] |> ReviewChecklistItem.makeFromJs,
    ~coaches= Js.Array.map(Coach.makeFromJs, details["coaches"]),
    ~teamName=details["teamName"],
    ~courseId=details["courseId"]
  )

// let updateSubmission = (submission, t) => {
//   ...t,
//   submissions: t.submissions |> Js.Array.map(s =>
//     OverlaySubmission.id(s) == OverlaySubmission.id(submission) ? submission : s
//   ),
// }

// let makeIndexSubmission = (overlaySubmission, t) =>
//   IndexSubmission.make(
//     ~id=overlaySubmission |> OverlaySubmission.id,
//     ~title=t.targetTitle,
//     ~createdAt=overlaySubmission |> OverlaySubmission.createdAt,
//     ~levelId=t.levelId,
//     ~userNames=t.students
//     |> Js.Array.map(student => student |> CoursesReview__Student.name)
//     |> Js.Array.joinWith(", "),
//     ~status=Some(
//       IndexSubmission.makeStatus(
//         ~passedAt=overlaySubmission |> OverlaySubmission.passedAt,
//         ~feedbackSent=overlaySubmission |> OverlaySubmission.feedbackSent,
//       ),
//     ),
//     ~coachIds=t.coachIds,
//     ~teamName=t.teamName,
//     ~levelNumber=0,
//   )

let updateReviewChecklist = (reviewChecklist, t) => {...t, reviewChecklist: reviewChecklist}
