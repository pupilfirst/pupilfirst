type t = {
  id: int,
  name: string,
  description: string,
  endsAt: option(Js.Date.t),
  maxGrade: int,
  passGrade: int,
  gradesAndLabels: list(CourseEditor__GradesAndLabels.t),
  enableLeaderboard: bool,
  about: option(string),
  publicSignup: bool,
};

let name = t => t.name;

let id = t => t.id;

let endsAt = t => t.endsAt;

let about = t => t.about;

let publicSignup = t => t.publicSignup;

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
      about,
      publicSignup,
    ) => {
  id,
  name,
  description,
  endsAt,
  maxGrade,
  passGrade,
  gradesAndLabels,
  enableLeaderboard,
  about,
  publicSignup,
};
