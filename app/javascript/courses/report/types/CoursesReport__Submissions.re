type t =
  | Unloaded
  | PartiallyLoaded(array(CoursesReport__Submission.t), cursor)
  | FullyLoaded(array(CoursesReport__Submission.t))
and cursor = string;
