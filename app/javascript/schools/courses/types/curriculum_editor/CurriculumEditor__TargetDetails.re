exception InvalidVisibilityValue(string);
exception InvalidRoleValue(string);

type role =
  | Student
  | Team;

type visibility =
  | Draft
  | Live
  | Archived;

type methodOfCompletion =
  | Evaluated
  | VisitLink
  | TakeQuiz
  | MarkAsComplete;

type t = {
  title: string,
  role,
  evaluationCriteria: array(string),
  prerequisiteTargets: array(string),
  targetGroupId: string,
  quiz: array(TargetDetails__QuizQuestion.t),
  linkToComplete: option(string),
  visibility,
  completionInstructions: option(string),
};

let role = t => t.role;

let visibility = t => t.visibility;

let decodeVisbility = visibilityString =>
  switch (visibilityString) {
  | "draft" => Draft
  | "live" => Live
  | "archived" => Archived
  | _ => raise(InvalidVisibilityValue("Unknown Value"))
  };

let decodeRole = roleString =>
  switch (roleString) {
  | "student" => Student
  | "team" => Team
  | role => raise(InvalidRoleValue("Unknown Value :" ++ role))
  };

let makeFromJs = targetData => {
  title: targetData##title,
  role: decodeRole(targetData##role),
  targetGroupId: targetData##targetGroupId,
  evaluationCriteria: targetData##evaluationCriteria,
  prerequisiteTargets: targetData##prerequisiteTargets,
  quiz:
    targetData##quiz
    |> Array.map(quizQuestion =>
         quizQuestion |> TargetDetails__QuizQuestion.makeFromJs
       ),
  linkToComplete: targetData##linkToComplete,
  completionInstructions: targetData##completionInstructions,
  visibility: decodeVisbility(targetData##visibility),
};
