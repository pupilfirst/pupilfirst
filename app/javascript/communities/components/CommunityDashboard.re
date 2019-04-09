let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("CommunityDashboard");

let make = (~authenticityToken, _children) => {
  ...component,
  render: _self =>
    <div>
      <h1> {"Community Dashboard" |> str} </h1>
      <span> {authenticityToken |> str} </span>
    </div>,
};