type averageGrade = {
  evaluationCriterionId: string,
  grade: float,
};

type t = {
  id: string,
  email: string,
  phone: option(string),
  evaluationCriteria: array(CoursesCurriculum__EvaluationCriterion.t),
  socialLinks: array(string),
  totalTargets: int,
  targetsCompleted: int,
  team: CoursesCurriculum__TeamInfo.t,
  quizScores: array(string),
  averageGrades: array(averageGrade),
  completedLevelIds: array(string),
};

let team = t => t.team;
let email = t => t.email;

let phone = t => t.phone;

let socialLinks = t => t.socialLinks;

let levelId = t => t.team |> CoursesCurriculum__TeamInfo.levelId;

let makeAverageGrade = gradesData => {
  gradesData
  |> Js.Array.map(gradeData =>
       {
         evaluationCriterionId: gradeData##evaluationCriterionId,
         grade: gradeData##averageGrade,
       }
     );
};

let totalTargets = t => t.totalTargets |> float_of_int;

let gradeAsPercentage =
    (
      averageGrade: averageGrade,
      evaluationCriterion: CoursesCurriculum__EvaluationCriterion.t,
    ) => {
  let maxGrade = evaluationCriterion.maxGrade |> float_of_int;
  averageGrade.grade /. maxGrade *. 100.0 |> int_of_float |> string_of_int;
};

let targetsCompleted = t => t.targetsCompleted |> float_of_int;

let quizzesAttempted = t => t.quizScores |> Array.length |> string_of_int;

let evaluationCriteria = t => t.evaluationCriteria;

let averageGrades = t => t.averageGrades;

let completedLevelIds = t => t.completedLevelIds;

let gradeValue = averageGrade => averageGrade.grade;

let student = t => t.team |> CoursesCurriculum__TeamInfo.studentWithId(t.id);

let title = t => t |> student |> CoursesCurriculum__TeamInfo.studentTitle;

let avatarUrl = t =>
  t |> student |> CoursesCurriculum__TeamInfo.studentAvatarUrl;

let name = t => t |> student |> CoursesCurriculum__TeamInfo.studentName;

let evaluationCriterionForGrade = (grade, evaluationCriteria, componentName) => {
  evaluationCriteria
  |> ArrayUtils.unsafeFind(
       ec =>
         CoursesCurriculum__EvaluationCriterion.id(ec)
         == grade.evaluationCriterionId,
       "Unable to find evaluation criterion with id: "
       ++ grade.evaluationCriterionId
       ++ " in component: "
       ++ componentName,
     );
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

let teamHasManyStudents = t =>
  t.team |> CoursesCurriculum__TeamInfo.students |> Array.length > 1;

let makeFromJs = (id, studentDetails) => {
  id,
  email: studentDetails##email,
  phone: studentDetails##phone,
  evaluationCriteria:
    studentDetails##evaluationCriteria
    |> CoursesCurriculum__EvaluationCriterion.makeFromJs,
  socialLinks: studentDetails##socialLinks,
  totalTargets: studentDetails##totalTargets,
  targetsCompleted: studentDetails##targetsCompleted,
  quizScores: studentDetails##quizScores,
  averageGrades: studentDetails##averageGrades |> makeAverageGrade,
  completedLevelIds: studentDetails##completedLevelIds,
  team: studentDetails##team |> CoursesCurriculum__TeamInfo.makeFromJS,
};
