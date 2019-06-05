[@bs.config {jsx: 3}];

let str = React.string;

[@react.component]
let make = (~message, ~active) =>
  if (active) {
    <div className="mt-2 text-red inline-flex items-center">
      <span className="ml-4 mr-2"> <Icon kind=Icon.Alert size="3" /> </span>
      <span> {message |> str} </span>
    </div>;
  } else {
    ReasonReact.null;
  };

module Jsx2 = {
  let component = ReasonReact.statelessComponent("SchoolInputGroupError");

  let make = (~message, ~active, children) =>
    ReasonReactCompat.wrapReactForReasonReact(
      make,
      makeProps(~message, ~active, ()),
      children,
    );
};