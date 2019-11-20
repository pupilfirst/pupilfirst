type t = {
  title: string,
  email: string,
  phone: option(string),
  notes: option(array(CoursesStudents__CoachNote.t)),
  submissions: option(array(CoursesStudents__Submission.t)),
  evaluationCriteria: array(CoursesStudents__EvaluationCriterion.t),
  levelId: string,
  socialLinks: option(array(string)),
};

let makeFromJS = studentDetails => {
  title: studentDetails##title,
  email: studentDetails##email,
  phone: None,
  notes: None,
  submissions: None,
  evaluationCriteria: [||],
  levelId: studentDetails##levelId,
  socialLinks: None,
};
