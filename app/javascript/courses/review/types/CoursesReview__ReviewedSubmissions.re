module Level = CoursesReview__Level;

type filter = {
  level: option(Level.t),
  coach: option(UserProxy.t),
};

let makeFilter = (level, coach) => {level, coach};

let filterLevelId = level =>
  level |> OptionUtils.mapWithDefault(Level.id, "none");
let filterCoachId = coach =>
  coach |> OptionUtils.mapWithDefault(UserProxy.id, "none");

let filterEq = (level, coach, filter) =>
  filter.level
  |> filterLevelId == filterLevelId(level)
  && filter.coach
  |> filterCoachId == filterCoachId(coach);

type sortDirection = [ | `Up | `Down];

type t =
  | Unloaded
  | PartiallyLoaded(
      array(CoursesReview__IndexSubmission.t),
      filter,
      sortDirection,
      string,
    )
  | FullyLoaded(
      array(CoursesReview__IndexSubmission.t),
      filter,
      sortDirection,
    );
