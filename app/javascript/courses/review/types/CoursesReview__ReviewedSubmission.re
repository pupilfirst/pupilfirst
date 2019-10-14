type t =
  | Unloaded
  | PartiallyLoaded(array(CoursesReview__SubmissionInfo.t), string)
  | FullyLoaded(array(CoursesReview__SubmissionInfo.t));
