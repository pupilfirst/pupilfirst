[%bs.raw {|require("./SidePanel.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("SidePanel");

let make =
    (
      ~coach,
      ~startups,
      ~selectedStartupId,
      ~selectStartupCB,
      ~clearStartupCB,
      _children,
    ) => {
  ...component,
  render: _self =>
    <div className="side-panel__container d-flex flex-column">
      <h3 className="side-panel__coach-greeting py-3">
        ("Welcome " ++ (coach |> Coach.name) |> str)
      </h3>
      <StartupsList
        startups
        selectedStartupId
        selectStartupCB
        clearStartupCB
      />
    </div>,
};