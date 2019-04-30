let component = ReasonReact.statelessComponent("FaIcon");

let make = (~classes, _children) => {
  ...component,
  render: _self => <span key=classes> <i className=classes /> </span>,
};