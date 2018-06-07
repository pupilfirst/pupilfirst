let component = ReasonReact.statelessComponent("Faculty Dashboard");

let make = (~name, ~age, _children) => {
  ...component,
  render: _self =>
    <button> (ReasonReact.string("Hello" ++ name ++ "Age" ++ age)) </button>,
};

/* let element = ReasonReact.element; */
[@bs.deriving abstract]
type jsProps = {
  name: string,
  age: string,
};

let jsComponent =
  ReasonReact.wrapReasonForJs(~component, jsProps =>
    make(~name=jsProps |. name, ~age=jsProps |. age, [||])
  );