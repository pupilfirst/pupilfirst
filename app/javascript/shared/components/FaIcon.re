[@bs.config {jsx: 3}]
[@react.component]
let make = (~classes) => <span key=classes> <i className=classes /> </span>;

module Jsx2 = {
  let component = ReasonReact.statelessComponent("FaIcon");

  let make = (~classes, children) =>
    ReasonReactCompat.wrapReactForReasonReact(
      make,
      makeProps(~classes, ()),
      children,
    );
};