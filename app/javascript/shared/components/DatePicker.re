[@bs.config {jsx: 3}];

module JsComponent = {
  [@bs.module "./DatePicker"] [@react.component]
  external make:
    (
      ~id: string=?,
      ~onChange: Js.Nullable.t(Js.Date.t) => unit,
      ~selected: Js.Date.t=?
    ) =>
    React.element =
    "default";
};

[@react.component]
let make = (~onChange, ~selected=?, ~id=?) => {
  <JsComponent
    ?id
    onChange={date => onChange(date |> Js.Nullable.toOption)}
    ?selected
  />;
};

module Jsx2 = {
  let component = ReasonReact.statelessComponent("DayPicker");

  let make = (~onChange, ~selected=?, ~id=?, children) =>
    ReasonReactCompat.wrapReactForReasonReact(
      make,
      makeProps(~onChange, ~selected?, ~id?, ()),
      children,
    );
};
