type t = {
  label: string,
  grade: int,
};

let decode = json =>
  Json.Decode.{
    label: json |> field("label", string),
    grade: json |> field("grade", string) |> int_of_string,
  };

let grade = t => t.grade;

let label = t => t.label;