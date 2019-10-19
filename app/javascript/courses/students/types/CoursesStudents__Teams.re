type t =
  | Unloaded
  | PartiallyLoaded(array(CoursesStudents__TeamInfo.t), string)
  | FullyLoaded(array(CoursesStudents__TeamInfo.t));
