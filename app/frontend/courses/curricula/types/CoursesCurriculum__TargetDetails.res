type navigation = {
  previous: option<string>,
  next: option<string>,
}

type t = {
  pendingUserIds: array<string>,
  submissions: array<CoursesCurriculum__Submission.t>,
  feedback: array<CoursesCurriculum__Feedback.t>,
  quizQuestions: array<CoursesCurriculum__QuizQuestion.t>,
  contentBlocks: array<ContentBlock.t>,
  communities: array<CoursesCurriculum__Community.t>,
  linkToComplete: option<string>,
  evaluated: bool,
  grading: array<CoursesCurriculum__Grade.t>,
  completionInstructions: option<string>,
  navigation: navigation,
  checklist: array<TargetChecklistItem.t>,
}

let submissions = t => t.submissions

let pendingUserIds = t => t.pendingUserIds
let feedback = t => t.feedback
let navigation = t => (t.navigation.previous, t.navigation.next)
let checklist = t => t.checklist

type completionType =
  | Evaluated
  | TakeQuiz
  | LinkToComplete
  | MarkAsComplete

let decodeNavigation = json => {
  open Json.Decode
  {
    previous: json |> optional(field("previous", string)),
    next: json |> optional(field("next", string)),
  }
}

let decode = json => {
  open Json.Decode
  {
    pendingUserIds: json |> field("pendingUserIds", array(string)),
    submissions: json |> field("submissions", array(CoursesCurriculum__Submission.decode)),
    feedback: json |> field("feedback", array(CoursesCurriculum__Feedback.decode)),
    quizQuestions: json |> field("quizQuestions", array(CoursesCurriculum__QuizQuestion.decode)),
    contentBlocks: json |> field("contentBlocks", array(ContentBlock.decode)),
    communities: json |> field("communities", array(CoursesCurriculum__Community.decode)),
    linkToComplete: json |> field("linkToComplete", nullable(string)) |> Js.Null.toOption,
    evaluated: json |> field("evaluated", bool),
    grading: json |> field("grading", array(CoursesCurriculum__Grade.decode)),
    completionInstructions: json
    |> field("completionInstructions", nullable(string))
    |> Js.Null.toOption,
    navigation: json |> field("navigation", decodeNavigation),
    checklist: json |> field("checklist", array(TargetChecklistItem.decode)),
  }
}

let computeCompletionType = targetDetails => {
  let evaluated = targetDetails.evaluated
  let hasQuiz = Js.Array.length(targetDetails.quizQuestions) > 0

  let hasLinkToComplete = switch targetDetails.linkToComplete {
  | Some(_) => true
  | None => false
  }

  switch (evaluated, hasQuiz, hasLinkToComplete) {
  | (true, _, _) => Evaluated
  | (false, true, _) => TakeQuiz
  | (false, false, true) => LinkToComplete
  | (_, _, _) => MarkAsComplete
  }
}

let contentBlocks = t => t.contentBlocks
let quizQuestions = t => t.quizQuestions
let communities = t => t.communities
let linkToComplete = t => t.linkToComplete

let completionInstructions = t => t.completionInstructions

let grades = (submissionId, t) =>
  t.grading |> Js.Array.filter(grade =>
    grade |> CoursesCurriculum__Grade.submissionId == submissionId
  )

let addSubmission = (submission, t) => {
  ...t,
  submissions: Js.Array.concat([submission], submissions(t)),
}

let clearPendingUserIds = t => {...t, pendingUserIds: []}
