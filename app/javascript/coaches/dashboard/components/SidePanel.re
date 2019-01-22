[%bs.raw {|require("./SidePanel.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("SidePanel");

let make = (~teams, ~founders, ~selectedFounder, ~selectFounderCB, ~clearFounderCB, _children) => {
  ...component,
  render: _self =>
    <div className="side-panel__container d-flex flex-column">
      <FoundersList teams founders selectedFounder selectFounderCB clearFounderCB />
    </div>,
};
