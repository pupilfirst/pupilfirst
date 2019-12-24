type t =
  | MarkAsComplete
  | VisitLink(string)
  | TakeQuiz(quiz)
  | Evaluated(evaluationCriteriaIds)
and quiz = list(CurriculumEditor__QuizQuestion.t)
and evaluationCriteriaIds = list(string);
