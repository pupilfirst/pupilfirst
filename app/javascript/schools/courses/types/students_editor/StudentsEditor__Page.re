type t =
  | Unloaded
  | PartiallyLoaded(array(StudentsEditor__Team.t), cursor)
  | FullyLoaded(array(StudentsEditor__Team.t))
and cursor = string;
