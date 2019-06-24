type t = {
  id: int,
  name: string,
  description: string,
  endsAt: option(string),
  maxGrade: int,
  passGrade: int,
  gradesAndLabels: list(CourseEditor__GradesAndLabels.t),
  enableLeaderboard: bool,
};

let name = t => t.name;

let id = t => t.id;

let endsAt = t => t.endsAt;

let description = t => t.description;

let maxGrade = t => t.maxGrade;

let passGrade = t => t.passGrade;

let gradesAndLabels = t => t.gradesAndLabels;

let enableLeaderboard = t => t.enableLeaderboard;

let sort = courses => courses |> List.sort((x, y) => x.id - y.id);

let updateList = (courses, course) => {
  let oldCourses = courses |> List.filter(c => c.id !== course.id);
  oldCourses |> List.rev |> List.append([course]) |> List.rev;
};

let create =
    (
      id,
      name,
      description,
      endsAt,
      maxGrade,
      passGrade,
      gradesAndLabels,
      enableLeaderboard,
    ) => {
  id,
  name,
  description,
  endsAt,
  maxGrade,
  passGrade,
  gradesAndLabels,
  enableLeaderboard,
};