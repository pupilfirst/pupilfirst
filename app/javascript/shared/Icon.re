[@bs.config {jsx: 3}];

[@bs.module "./pupilFirstIcons"]
external transformIcons: unit => unit = "transformIcons";

[@react.component]
let make = (~className) => {
  React.useEffect1(
    () => {
      transformIcons();
      None;
    },
    [|className|],
  );
  <span key=className> <i className /> </span>;
};

module Jsx2 = {
  let component = ReasonReact.statelessComponent("Icon");

  let make = (~className, children) =>
    ReasonReactCompat.wrapReactForReasonReact(
      make,
      makeProps(~className, ()),
      children,
    );
};
