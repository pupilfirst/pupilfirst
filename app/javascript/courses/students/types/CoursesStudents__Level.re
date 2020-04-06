type t = {
  id: string,
  name: string,
  number: int,
  studentsInLevel: int,
};

let id = t => t.id;
let name = t => t.name;

let number = t => t.number;

let studentsInLevel = t => t.studentsInLevel;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    number: json |> field("number", int),
    studentsInLevel: json |> field("studentsInLevel", int),
  };

let percentageStudents = (t, totalStudents) => {
  float_of_int(t.studentsInLevel) /. float_of_int(totalStudents) *. 100.0;
};

let shortName = t => {
  "L" ++ (t.number |> string_of_int);
};

let sort = levels =>
  levels |> ArrayUtils.copyAndSort((x, y) => x.number - y.number);

let unsafeLevelNumber = (levels, componentName, levelId) =>
  "Level "
  ++ (
    levels
    |> ArrayUtils.unsafeFind(
         l => l.id == levelId,
         "Unable to find level with id: "
         ++ levelId
         ++ " in CoursesStudents__"
         ++ componentName,
       )
    |> number
    |> string_of_int
  );
