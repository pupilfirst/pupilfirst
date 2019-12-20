type t;

let decode: Js.Json.t => t;

let id: t => string;

let name: t => string;

let passGrade: t => int;

let gradesAndLabels: t => array(GradeLabel.t);

let make:
  (
    ~id: string,
    ~name: string,
    ~maxGrade: int,
    ~passGrade: int,
    ~gradesAndLabels: array(GradeLabel.t)
  ) =>
  t;
