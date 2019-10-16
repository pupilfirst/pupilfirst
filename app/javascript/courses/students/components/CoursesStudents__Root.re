[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesStudents__Root.css")|}];

open CoursesStudents__Types;

[@react.component]
let make = (~authenticityToken, ~levels, ~course, ~students, ~teams) =>
  <div />;
