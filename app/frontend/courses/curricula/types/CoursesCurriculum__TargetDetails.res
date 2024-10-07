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
    previous: option(field("previous", string), json),
    next: option(field("next", string), json),
  }
}

let decode = json => {
  open Json.Decode
  {
    pendingUserIds: field("pendingUserIds", array(string), json),
    submissions: field("submissions", array(CoursesCurriculum__Submission.decode), json),
    feedback: field("feedback", array(CoursesCurriculum__Feedback.decode), json),
    quizQuestions: field("quizQuestions", array(CoursesCurriculum__QuizQuestion.decode), json),
    contentBlocks: field("contentBlocks", array(ContentBlock.decode), json),
    communities: field("communities", array(CoursesCurriculum__Community.decode), json),
    comments: field("comments", array(CoursesCurriculum__SubmissionComment.decode), json),
    reactions: field("reactions", array(CoursesCurriculum__Reaction.decode), json),
    evaluated: field("evaluated", bool, json),
    grading: field("grading", array(CoursesCurriculum__Grade.decode), json),
    completionInstructions: Js.Null.toOption(
      field("completionInstructions", nullable(string), json),
    ),
    navigation: field("navigation", decodeNavigation, json),
    checklist: field("checklist", array(TargetChecklistItem.decode), json),
    discussion: field("discussion", bool, json),
    allowAnonymous: field("allowAnonymous", bool, json),
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
  Js.Array.filter(grade => CoursesCurriculum__Grade.submissionId(grade) == submissionId, t.grading)

let addSubmission = (submission, t) => {
  ...t,
  submissions: Js.Array.concat([submission], submissions(t)),
}

let clearPendingUserIds = t => {...t, pendingUserIds: []}
