let component = ReasonReact.statelessComponent("Coach Dashboard");

let make = (~coachName, _children) => {
  ...component,
  render: _self => <button> (ReasonReact.string("Welcome " ++ coachName)) </button>,
};

[@bs.deriving abstract]
type jsProps = {coachName: string};

let jsComponent = ReasonReact.wrapReasonForJs(~component, jsProps => make(~coachName=jsProps |. coachName, [||]));
