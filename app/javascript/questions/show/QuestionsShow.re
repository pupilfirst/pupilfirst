[@bs.config {jsx: 3}];

[@react.component]
let make = (~authenticityToken) =>
  <div> <p> {React.string(authenticityToken ++ " clicked ")} </p> </div>;