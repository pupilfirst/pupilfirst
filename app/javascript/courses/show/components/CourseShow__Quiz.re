[@bs.config {jsx: 3}];

let str = React.string;

[@react.component]
let make = (~target, ~quizQuestions) =>
  <div> {"Quiz should go here" |> str} </div>;