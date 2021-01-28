module OverlaySubmission = CoursesReview__OverlaySubmission
module IndexSubmission = CoursesReview__IndexSubmission
module Student = CoursesReview__Student
module ReviewChecklistItem = CoursesReview__ReviewChecklistItem

type t = {
  submissions: array<OverlaySubmission.t>,
  targetId: string,
  targetTitle: string,
  students: array<Student.t>,
  levelNumber: string,
  levelId: string,
  evaluationCriteria: array<EvaluationCriterion.t>,
  reviewChecklist: array<ReviewChecklistItem.t>,
  targetEvaluationCriteriaIds: array<string>,
  inactiveStudents: bool,
  coachIds: array<string>,
  teamName: option<string>,
}
let submissions = t => t.submissions
let targetId = t => t.targetId
let targetTitle = t => t.targetTitle
let levelNumber = t => t.levelNumber
let students = t => t.students
let evaluationCriteria = t => t.evaluationCriteria
let reviewChecklist = t => t.reviewChecklist
let targetEvaluationCriteriaIds = t => t.targetEvaluationCriteriaIds
let inactiveStudents = t => t.inactiveStudents
let coachIds = t => t.coachIds
let teamName = t => t.teamName

let make = (
  ~submissions,
  ~targetId,
  ~targetTitle,
  ~students,
  ~levelNumber,
  ~evaluationCriteria,
  ~levelId,
  ~reviewChecklist,
  ~targetEvaluationCriteriaIds,
  ~inactiveStudents,
  ~coachIds,
  ~teamName,
) => {
  submissions: submissions,
  targetId: targetId,
  targetTitle: targetTitle,
  students: students,
  levelNumber: levelNumber,
  evaluationCriteria: evaluationCriteria,
  levelId: levelId,
  reviewChecklist: reviewChecklist,
  targetEvaluationCriteriaIds: targetEvaluationCriteriaIds,
  inactiveStudents: inactiveStudents,
  coachIds: coachIds,
  teamName: teamName,
}

let decodeJs = details =>
  make(
    ~submissions=details["submissions"] |> OverlaySubmission.makeFromJs,
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
    ~coachIds=details["coachIds"],
    ~teamName=details["teamName"],
  )

let updateSubmission = (submission, t) => {
  ...t,
  submissions: t.submissions |> Js.Array.map(s =>
    OverlaySubmission.id(s) == OverlaySubmission.id(submission) ? submission : s
  ),
}

let makeIndexSubmission = (overlaySubmission, t) =>
  IndexSubmission.make(
    ~id=overlaySubmission |> OverlaySubmission.id,
    ~title=t.targetTitle,
    ~createdAt=overlaySubmission |> OverlaySubmission.createdAt,
    ~levelId=t.levelId,
    ~userNames=t.students
    |> Js.Array.map(student => student |> CoursesReview__Student.name)
    |> Js.Array.joinWith(", "),
    ~status=Some(
      IndexSubmission.makeStatus(
        ~passedAt=overlaySubmission |> OverlaySubmission.passedAt,
        ~feedbackSent=overlaySubmission |> OverlaySubmission.feedbackSent,
      ),
    ),
    ~coachIds=t.coachIds,
    ~teamName=t.teamName,
  )

let updateReviewChecklist = (reviewChecklist, t) => {...t, reviewChecklist: reviewChecklist}
