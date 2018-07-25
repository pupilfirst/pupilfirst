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
      <div className="side-panel__coach-profile d-lg-flex text-center text-lg-left align-items-center p-4">
        <div className="side-panel__coach-profile-dp mb-3 mb-lg-0 mx-lg-0 mx-auto">

        </div>
        <div className="side-panel__coach-profile-details d-flex flex-column">
          <h3 className="side-panel__coach-name font-semibold px-3 mb-1">
            ((coach |> Coach.name) |> str)
          </h3>
          <p className="px-3 side-panel__coach-description">
            ("Laborum dolores dignissimos" |> str)
          </p>
        </div>
      </div>
      <StartupsList
        startups
        selectedStartupId
        selectStartupCB
        clearStartupCB
      />
    </div>,
};