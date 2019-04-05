[%bs.raw {|require("./SchoolCustomize.css")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("SchoolCustomize");

let make = (~authenticityToken, _children) => {
  ...component,
  render: _self =>
    <div>
      <h1> {"Customize School" |> str} </h1>
      <span> {authenticityToken |> str} </span>
    </div>,
};