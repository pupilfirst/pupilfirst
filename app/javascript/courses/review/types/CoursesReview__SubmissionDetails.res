module OverlaySubmission = CoursesReview__OverlaySubmission
module IndexSubmission = CoursesReview__IndexSubmission
module Student = CoursesReview__Student
module ReviewChecklistItem = CoursesReview__ReviewChecklistItem
module SubmissionMeta = CoursesReview__SubmissionMeta
module Coach = UserProxy
module Reviewer = CoursesReview__Reviewer
module SubmissionReport = CoursesReview__SubmissionReport

type t = {
  submission: OverlaySubmission.t,
  createdAt: Js.Date.t,
  allSubmissions: array<SubmissionMeta.t>,
  targetId: string,
  targetTitle: string,
  students: array<Student.t>,
  levelNumber: string,
  levelId: string,
  submissionReport: option<SubmissionReport.t>,
  evaluationCriteria: array<EvaluationCriterion.t>,
  reviewChecklist: array<ReviewChecklistItem.t>,
  targetEvaluationCriteriaIds: array<string>,
  inactiveStudents: bool,
  coaches: array<Coach.t>,
  teamName: option<string>,
  courseId: string,
  preview: bool,
  reviewer: option<Reviewer.t>,
  submissionReportPollTime: int,
}

let submission = t => t.submission
let allSubmissions = t => t.allSubmissions
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
let courseId = t => t.courseId
let createdAt = t => t.createdAt
let preview = t => t.preview
let reviewer = t => t.reviewer
let submissionReport = t => t.submissionReport
let submissionReportPollTime = t => t.submissionReportPollTime

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
  ~submissionReport,
  ~coaches,
  ~teamName,
  ~courseId,
  ~createdAt,
  ~preview,
  ~reviewer,
  ~submissionReportPollTime,
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
  submissionReport: submissionReport,
  coaches: coaches,
  teamName: teamName,
  courseId: courseId,
  createdAt: createdAt,
  preview: preview,
  reviewer: reviewer,
  submissionReportPollTime: submissionReportPollTime,
}

let decodeJs = details =>
  make(
    ~submission=OverlaySubmission.makeFromJs(details["submission"]),
    ~allSubmissions=ArrayUtils.copyAndSort(
      (s1, s2) =>
        DateFns.differenceInSeconds(SubmissionMeta.createdAt(s2), SubmissionMeta.createdAt(s1)),
      SubmissionMeta.makeFromJs(details["allSubmissions"]),
    ),
    ~targetId=details["targetId"],
    ~targetTitle=details["targetTitle"],
    ~students=details["students"]->Js.Array2.map(Student.makeFromJs),
    ~levelNumber=details["levelNumber"],
    ~levelId=details["levelId"],
    ~targetEvaluationCriteriaIds=details["targetEvaluationCriteriaIds"],
    ~inactiveStudents=details["inactiveStudents"],
    ~createdAt=DateFns.decodeISO(details["createdAt"]),
    ~evaluationCriteria=details["evaluationCriteria"]->Js.Array2.map(ec =>
      EvaluationCriterion.make(
        ~id=ec["id"],
        ~name=ec["name"],
        ~maxGrade=ec["maxGrade"],
        ~passGrade=ec["passGrade"],
        ~gradesAndLabels=ec["gradeLabels"]->Js.Array2.map(gradeAndLabel =>
          GradeLabel.makeFromJs(gradeAndLabel)
        ),
      )
    ),
    ~reviewChecklist=ReviewChecklistItem.makeFromJs(details["reviewChecklist"]),
    ~coaches=Js.Array.map(Coach.makeFromJs, details["coaches"]),
    ~submissionReport=Belt.Option.map(details["submissionReport"], SubmissionReport.makeFromJS),
    ~teamName=details["teamName"],
    ~courseId=details["courseId"],
    ~preview=details["preview"],
    ~reviewer=Belt.Option.map(details["reviewerDetails"], Reviewer.makeFromJs),
    ~submissionReportPollTime=details["submissionReportPollTime"],
  )

let updateMetaSubmission = submission => {
  SubmissionMeta.make(
    ~id=OverlaySubmission.id(submission),
    ~createdAt=OverlaySubmission.createdAt(submission),
    ~passedAt=OverlaySubmission.passedAt(submission),
    ~evaluatedAt=OverlaySubmission.evaluatedAt(submission),
    ~feedbackSent=ArrayUtils.isNotEmpty(OverlaySubmission.feedback(submission)),
    ~archivedAt=OverlaySubmission.archivedAt(submission),
  )
}

let updateOverlaySubmission = (submission, t) => {
  ...t,
  submission: submission,
  allSubmissions: Js.Array.map(
    s =>
      SubmissionMeta.id(s) == OverlaySubmission.id(submission)
        ? updateMetaSubmission(submission)
        : s,
    t.allSubmissions,
  ),
}

let updateReviewChecklist = (reviewChecklist, t) => {...t, reviewChecklist: reviewChecklist}

let updateReviewer = (user, t) => {
  ...t,
  reviewer: Belt.Option.map(user, Reviewer.setReviewer),
}

let updateSubmissionReport = (report, t) => {
  ...t,
  submissionReport: report,
}
