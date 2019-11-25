type averageGrade = {
  evaluationCriterionId: string,
  grade: float,
};

type t = {
  name: string,
  title: string,
  email: string,
  avatarUrl: option(string),
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

let name = t => t.name;

let title = t => t.title;

let avatarUrl = t => t.avatarUrl;

let makeAverageGrade = gradesData => {
  gradesData
  |> Js.Array.map(gradeData =>
       {evaluationCriterionId: gradeData##id, grade: gradeData##averageGrade}
     );
};

let totalTargets = t => t.totalTargets |> float_of_int;

let targetsCompleted = t => t.targetsCompleted |> float_of_int;

let quizzesAttempted = t => t.quizScores |> Array.length |> string_of_int;

let computeAverageQuizScore = quizScores => {
  let sumOfPercentageScores =
    quizScores
    |> Array.map(quizScore => {
         let fractionArray =
           quizScore |> String.split_on_char('/') |> Array.of_list;
         let (numerator, denominator) = (
           fractionArray[0] |> float_of_string,
           fractionArray[1] |> float_of_string,
         );
         numerator /. denominator *. 100.0;
       })
    |> Js.Array.reduce((a, b) => a +. b, 0.0);
  sumOfPercentageScores /. (quizScores |> Array.length |> float_of_int);
};

let averageQuizScore = t => {
  t.quizScores |> ArrayUtils.isEmpty
    ? None : Some(computeAverageQuizScore(t.quizScores));
};

let makeFromJS = studentDetails => {
  name: studentDetails##name,
  title: studentDetails##title,
  email: studentDetails##email,
  avatarUrl: studentDetails##avatarUrl,
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
