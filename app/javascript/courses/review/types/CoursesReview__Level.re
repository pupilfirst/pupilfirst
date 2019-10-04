type t = {
  id: string,
  name: string,
  number: int,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    number: json |> field("number", int),
  };

let id = t => t.id;
let name = t => t.name;
let number = t => t.number;

let sort = levels =>
  levels |> ArrayUtils.copyAndSort((x, y) => x.number - y.number);

let unsafeLevelNumber = (levels, componentName, levelId) =>
  "Level "
  ++ (
    switch (levels |> Js.Array.find(l => l |> id == levelId)) {
    | Some(l) => l |> number |> string_of_int
    | None =>
      Rollbar.error(
        "Unable to find level with id: "
        ++ levelId
        ++ "in CoursesRevew__"
        ++ componentName,
      );
      "Unknown";
    }
  );
