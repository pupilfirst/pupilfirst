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

let email = t => t.email;

let levelId = t => t.levelId;

let phone = t => t.phone;

let socialLinks = t => t.socialLinks;

let avatarUrl = t => t.avatarUrl;

let coachNotes = t => t.coachNotes;

let makeAverageGrade = gradesData => {
  gradesData
  |> Js.Array.map(gradeData =>
       {evaluationCriterionId: gradeData##id, grade: gradeData##averageGrade}
     );
};

let totalTargets = t => t.totalTargets |> float_of_int;

let gradeAsPercentage =
    (
      averageGrade: averageGrade,
      evaluationCriterion: CoursesStudents__EvaluationCriterion.t,
    ) => {
  let maxGrade = evaluationCriterion.maxGrade |> float_of_int;
  averageGrade.grade /. maxGrade *. 100.0 |> int_of_float |> string_of_int;
};

let targetsCompleted = t => t.targetsCompleted |> float_of_int;

let quizzesAttempted = t => t.quizScores |> Array.length |> string_of_int;

let evaluationCriteria = t => t.evaluationCriteria;

let averageGrades = t => t.averageGrades;

let gradeValue = averageGrade => averageGrade.grade;

let evaluationCriterionForGrade = (grade, evaluationCriteria, componentName) => {
  evaluationCriteria
  |> ArrayUtils.unsafeFind(
       ec =>
         CoursesStudents__EvaluationCriterion.id(ec)
         == grade.evaluationCriterionId,
       "Unable to find evaluation criterion with id: "
       ++ grade.evaluationCriterionId
       ++ "in component: "
       ++ componentName,
     );
};

let addNewNote = (note, t) => {
  let notes = Array.append(t.coachNotes, [|note|]);
  {...t, coachNotes: notes};
};

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
    studentDetails##coachNotes
    |> Js.Array.map(note => note |> CoursesStudents__CoachNote.makeFromJs),
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
