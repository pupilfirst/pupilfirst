exception InvalidRoleValue(string)

type role =
  | Student
  | Team

type t = {
  // title: string,
  role: role,
  evaluationCriteria: array<string>,
  prerequisiteTargets: array<string>,
  quiz: array<CurriculumEditor__QuizQuestion.t>,
  checklist: array<TargetChecklistItem.t>,
  completionInstructions: option<string>,
  milestone: bool,
  archived: bool,
  discussion: bool,
  allowAnonymous: bool,
}

let role = t => t.role

let quiz = t => t.quiz

let prerequisiteTargets = t => t.prerequisiteTargets

let evaluationCriteria = t => t.evaluationCriteria

let milestone = t => t.milestone

let archived = t => t.archived

let discussion = t => t.discussion

let allowAnonymous = t => t.allowAnonymous

let roleAsString = role =>
  switch role {
  | Student => "student"
  | Team => "team"
  }

let roleFromJs = roleString =>
  switch roleString {
  | "student" => Student
  | "team" => Team
  | role => raise(InvalidRoleValue("Unknown Value :" ++ role))
  }

let makeFromJs = assignmentData => {
  role: roleFromJs(assignmentData["role"]),
  evaluationCriteria: assignmentData["evaluationCriteria"],
  prerequisiteTargets: assignmentData["prerequisiteTargets"],
  quiz: assignmentData["quiz"] |> Array.map(quizQuestion =>
    quizQuestion |> CurriculumEditor__QuizQuestion.makeFromJs
  ),
  completionInstructions: assignmentData["completionInstructions"],
  checklist: assignmentData["checklist"] |> Json.Decode.array(TargetChecklistItem.decode),
  milestone: assignmentData["milestone"],
  archived: assignmentData["archived"],
  discussion: assignmentData["discussion"],
  allowAnonymous: assignmentData["allowAnonymous"],
}
