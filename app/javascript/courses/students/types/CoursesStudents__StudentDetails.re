type socialLink =
  | Github(string)
  | LinkedIn(string)
  | Instagram(string)
  | Twitter(string);

type t = {
  id: string,
  title: string,
  email: string,
  phone: option(string),
  notes: option(array(CoursesStudents__CoachNote.t)),
  submissions: array(CoursesStudents__Submission.t),
  grades: array(CoursesStudents__Grade.t),
  userNames: string,
  levelId: string,
  socialLinks: option(array(socialLink)),
};
