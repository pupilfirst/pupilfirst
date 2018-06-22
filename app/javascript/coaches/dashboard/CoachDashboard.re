module Coach = {
  [@bs.deriving abstract]
  type t = {
    name: string,
    id: int,
  };
};

[@bs.deriving abstract]
type jsProps = {coach: Coach.t};

let component = ReasonReact.statelessComponent("CoachDashboard");

let make = (~coach, _children) => {
  ...component,
  render: _self =>
    <button>
      (ReasonReact.string("Welcome Coach " ++ (coach |> Coach.name)))
    </button>,
};

let jsComponent =
  ReasonReact.wrapReasonForJs(~component, jsProps =>
    make(~coach=jsProps |. coach, [||])
  );