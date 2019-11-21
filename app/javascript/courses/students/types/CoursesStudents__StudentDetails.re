type averageGrade = {
  evaluationCriterionId: string,
  grade: float,
};

type t = {
  name: string,
  title: string,
  email: string,
  phone: option(string),
  coachNotes: array(CoursesStudents__CoachNote.t),
  evaluationCriteria: array(CoursesStudents__EvaluationCriterion.t),
  levelId: string,
  socialLinks: array(string),
  totalTargets: int,
  targetsCompleted: int,
  quizScores: array(string),
  averageGrades: array(averageGrade),
};

let makeAverageGrade = gradesData => {
  gradesData
  |> Js.Array.map(gradeData =>
       {evaluationCriterionId: gradeData##id, grade: gradeData##averageGrade}
     );
};

let makeFromJS = studentDetails => {
  name: studentDetails##name,
  title: studentDetails##title,
  email: studentDetails##email,
  phone: studentDetails##phone,
  coachNotes:
    studentDetails##coachNotes |> CoursesStudents__CoachNote.makeFromJs,
  evaluationCriteria:
    studentDetails##evaluationCriteria
    |> CoursesStudents__EvaluationCriterion.makeFromJs,
  levelId: studentDetails##levelId,
  socialLinks: studentDetails##socialLinks,
  totalTargets: studentDetails##totalTargets,
  targetsCompleted: studentDetails##targetsCompleted,
  quizScores: studentDetails##quizScores,
  averageGrades: studentDetails##averageGrades |> makeAverageGrade,
};
