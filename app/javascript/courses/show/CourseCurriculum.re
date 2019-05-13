[@bs.config {jsx: 3}]
[@react.component]
let make = (~authenticityToken, ~schoolName) => {
  Js.log2(authenticityToken, schoolName);
  <div> {"Boo!" |> React.string} </div>;
};

module Jsx2 = {
  let component = ReasonReact.statelessComponent("CourseCurriculum");

  let make = (~authenticityToken, ~schoolName, children) =>
    ReasonReactCompat.wrapReactForReasonReact(
      make,
      makeProps(~authenticityToken, ~schoolName, ()),
      children,
    );
};