[@bs.config {jsx: 3}];

let str = React.string;

[@react.component]
let make = (~target) =>
  <div> {"Target submission form should go here" |> str} </div>;