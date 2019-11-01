type t = {
  grade: int,
  label: string,
};

let grade = t => t.grade;

let label = t => t.label;

let create = (grade, label) => {grade, label};

let empty = grade => {grade, label: ""};

let update = (label, t) => {...t, label};

let asJsType = t => {"grade": t.grade, "label": t.label};

let valid = t => t.label |> Js.String.trim |> Js.String.length >= 1;
