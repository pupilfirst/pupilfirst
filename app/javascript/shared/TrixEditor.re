[@bs.deriving abstract]
type jsProps = {
  onChange: string => unit,
  autofocus: option(bool),
  input: option(string),
  placeholder: option(string),
  initialValue: option(string),
};

[@bs.module "./ReactTrixEditor"]
external jsTrixEditor: ReasonReact.reactClass = "default";
let make =
    (
      ~onChange,
      ~autofocus=?,
      ~input=?,
      ~placeholder=?,
      ~initialValue=?,
      children,
    ) =>
  ReasonReact.wrapJsForReason(
    ~reactClass=jsTrixEditor,
    ~props=
      jsProps(~onChange, ~autofocus, ~input, ~placeholder, ~initialValue),
    children,
  );