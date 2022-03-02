type t = {
  id: string,
  createdAt: Js.Date.t,
  passedAt: option<Js.Date.t>,
  evaluatorName: option<string>,
  evaluatedAt: option<Js.Date.t>,
  archivedAt: option<Js.Date.t>,
  feedback: array<CoursesReview__Feedback.t>,
  grades: array<CoursesReview__Grade.t>,
  checklist: array<SubmissionChecklistItem.t>,
}
let id = t => t.id
let createdAt = t => t.createdAt
let passedAt = t => t.passedAt
let evaluatorName = t => t.evaluatorName
let evaluatedAt = t => t.evaluatedAt
let grades = t => t.grades
let feedback = t => t.feedback
let checklist = t => t.checklist
let archivedAt = t => t.archivedAt

let make = (
  ~id,
  ~createdAt,
  ~passedAt,
  ~evaluatorName,
  ~feedback,
  ~grades,
  ~evaluatedAt,
  ~archivedAt,
  ~checklist,
) => {
  id: id,
  createdAt: createdAt,
  passedAt: passedAt,
  evaluatorName: evaluatorName,
  feedback: feedback,
  grades: grades,
  evaluatedAt: evaluatedAt,
  checklist: checklist,
  archivedAt: archivedAt,
}

let makeFromJs = s =>
  make(
    ~id=s["id"],
    ~createdAt=DateFns.decodeISO(s["createdAt"]),
    ~passedAt=s["passedAt"]->Belt.Option.map(DateFns.decodeISO),
    ~evaluatorName=s["evaluatorName"],
    ~evaluatedAt=s["evaluatedAt"]->Belt.Option.map(DateFns.decodeISO),
    ~feedback=s["feedback"] |> Js.Array.map(f =>
      CoursesReview__Feedback.make(
        ~coachName=f["coachName"],
        ~coachAvatarUrl=f["coachAvatarUrl"],
        ~coachTitle=f["coachTitle"],
        ~createdAt=DateFns.decodeISO(f["createdAt"]),
        ~value=f["value"],
      )
    ),
    ~grades=s["grades"] |> Js.Array.map(g =>
      CoursesReview__Grade.make(
        ~evaluationCriterionId=g["evaluationCriterionId"],
        ~value=g["grade"],
      )
    ),
    ~checklist=s["checklist"] |> Json.Decode.array(
      SubmissionChecklistItem.decode(SubmissionChecklistItem.makeFiles(s["files"])),
    ),
    ~archivedAt=s["archivedAt"]->Belt.Option.map(DateFns.decodeISO),
  )

let update = (passedAt, evaluatorName, feedback, grades, evaluatedAt, checklist, t) => {
  ...t,
  passedAt: passedAt,
  evaluatorName: evaluatorName,
  feedback: feedback,
  grades: grades,
  evaluatedAt: evaluatedAt,
  checklist: checklist,
}
let feedbackSent = t => t.feedback |> ArrayUtils.isNotEmpty

let updateFeedback = (feedback, t) => {...t, feedback: feedback}
