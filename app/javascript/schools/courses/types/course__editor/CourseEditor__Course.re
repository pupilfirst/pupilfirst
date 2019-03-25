type t = {
  id: int,
  name: string,
  endsAt: option(string),
  maxGrade: int,
  passGrade: int,
  gradesAndLabels: list(CourseEditor__GradesAndLabels.t),
};

let name = t => t.name;

let id = t => t.id;

let endsAt = t => t.endsAt;

let maxGrade = t => t.maxGrade;

let passGrade = t => t.passGrade;

let gradesAndLabels = t => t.gradesAndLabels;

let sort = courses => courses |> List.sort((x, y) => x.id - y.id);

let updateList = (courses, course) => {
  let oldCourses =
  courses |> List.filter(c => c.id !== course.id);
  oldCourses |> List.rev |> List.append([course]) |> List.rev;
};

let create = (id, name, endsAt, maxGrade, passGrade, gradesAndLabels) => {
  id,
  name,
  endsAt,
  maxGrade,
  passGrade,
  gradesAndLabels,
};