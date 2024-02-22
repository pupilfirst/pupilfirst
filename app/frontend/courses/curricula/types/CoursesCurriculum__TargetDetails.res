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
  comments: array<CoursesCurriculum__SubmissionComment.t>,
  reactions: array<CoursesCurriculum__Reaction.t>,
  evaluated: bool,
  grading: array<CoursesCurriculum__Grade.t>,
  completionInstructions: option<string>,
  navigation: navigation,
  checklist: array<TargetChecklistItem.t>,
  discussion: bool,
  allowAnonymous: bool,
}

let submissions = t => t.submissions

let pendingUserIds = t => t.pendingUserIds
let feedback = t => t.feedback
let navigation = t => (t.navigation.previous, t.navigation.next)
let checklist = t => t.checklist
let discussion = t => t.discussion
let allowAnonymous = t => t.allowAnonymous
let comments = t => t.comments
let reactions = t => t.reactions

type completionType =
  | Evaluated
  | TakeQuiz
  | SubmitForm
  | NoAssignment

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
    comments: json |> field("comments", array(CoursesCurriculum__SubmissionComment.decode)),
    reactions: json |> field("reactions", array(CoursesCurriculum__Reaction.decode)),
    evaluated: json |> field("evaluated", bool),
    grading: json |> field("grading", array(CoursesCurriculum__Grade.decode)),
    completionInstructions: json
    |> field("completionInstructions", nullable(string))
    |> Js.Null.toOption,
    navigation: json |> field("navigation", decodeNavigation),
    checklist: json |> field("checklist", array(TargetChecklistItem.decode)),
    discussion: json |> field("discussion", bool),
    allowAnonymous: json |> field("allowAnonymous", bool),
  }
}

let computeCompletionType = targetDetails => {
  let evaluated = targetDetails.evaluated
  let hasQuiz = Js.Array.length(targetDetails.quizQuestions) > 0

  let hasChecklist = Js.Array.length(targetDetails.checklist) > 0
  switch (evaluated, hasQuiz, hasChecklist) {
  | (true, _, _) => Evaluated
  | (false, true, _) => TakeQuiz
  | (false, false, true) => SubmitForm
  | (_, _, _) => NoAssignment
  }
}

let contentBlocks = t => t.contentBlocks
let quizQuestions = t => t.quizQuestions
let communities = t => t.communities

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
