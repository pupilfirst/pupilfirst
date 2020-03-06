type t =
  | Unloaded
  | PartiallyLoaded(array(CoursesReview__IndexSubmission.t), string)
  | FullyLoaded(array(CoursesReview__IndexSubmission.t));
