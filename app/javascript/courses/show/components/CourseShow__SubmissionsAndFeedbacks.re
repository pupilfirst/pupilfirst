[@bs.config {jsx: 3}];

let str = React.string;

open CourseShow__Types;

[@react.component]
let make = (~targetDetails) =>
  <div className="mt-4"> {"Submission and feedbacks" |> str} </div>;