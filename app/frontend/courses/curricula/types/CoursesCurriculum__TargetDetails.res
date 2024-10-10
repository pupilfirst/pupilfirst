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

module Decode = {
  open Json.Decode

  let decodeNavigation = object(field => {
    previous: field.optional("previous", string),
    next: field.optional("next", string),
  })

  let decode = object(field => {
    pendingUserIds: field.required("pendingUserIds", array(string)),
    submissions: field.required("submissions", array(CoursesCurriculum__Submission.decode)),
    feedback: field.required("feedback", array(CoursesCurriculum__Feedback.decode)),
    quizQuestions: field.required("quizQuestions", array(CoursesCurriculum__QuizQuestion.decode)),
    contentBlocks: field.required("contentBlocks", array(ContentBlock.Decode.decode)),
    communities: field.required("communities", array(CoursesCurriculum__Community.decode)),
    comments: field.required("comments", array(CoursesCurriculum__SubmissionComment.decode)),
    reactions: field.required("reactions", array(CoursesCurriculum__Reaction.decode)),
    evaluated: field.required("evaluated", bool),
    grading: field.required("grading", array(CoursesCurriculum__Grade.decode)),
    completionInstructions: field.optional("completionInstructions", string),
    navigation: field.required("navigation", decodeNavigation),
    checklist: field.required("checklist", array(TargetChecklistItem.decode)),
    discussion: field.required("discussion", bool),
    allowAnonymous: field.required("allowAnonymous", bool),
  })
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
