type t =
  | Unloaded
  | PartiallyLoaded(array(CoursesStudents__Submission.t), string)
  | FullyLoaded(array(CoursesStudents__Submission.t));
