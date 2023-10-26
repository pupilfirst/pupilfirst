exception InvalidRoleValue(string)

type role =
  | Student
  | Team

type t = {
  // title: string,
  role: role,
  evaluationCriteria: array<string>,
  prerequisiteAssignments: array<string>,
  quiz: array<CurriculumEditor__QuizQuestion.t>,
  checklist: array<TargetChecklistItem.t>,
  completionInstructions: option<string>,
  milestone: bool,
  archived: bool,
}

let role = t => t.role

let quiz = t => t.quiz

let prerequisiteAssignments = t => t.prerequisiteAssignments

let evaluationCriteria = t => t.evaluationCriteria

let milestone = t => t.milestone

let archived = t => t.archived

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
  prerequisiteAssignments: assignmentData["prerequisiteAssignments"],
  quiz: assignmentData["quiz"] |> Array.map(quizQuestion =>
    quizQuestion |> CurriculumEditor__QuizQuestion.makeFromJs
  ),
  completionInstructions: assignmentData["completionInstructions"],
  checklist: assignmentData["checklist"] |> Json.Decode.array(TargetChecklistItem.decode),
  milestone: assignmentData["milestone"],
  archived: assignmentData["archived"],
}
