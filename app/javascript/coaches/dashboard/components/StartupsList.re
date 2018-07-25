[%bs.raw {|require("./StartupsList.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("StartupsList");

let make =
    (
      ~startups,
      ~selectedStartupId,
      ~selectStartupCB,
      ~clearStartupCB,
      _children,
    ) => {
  ...component,
  render: _self =>
    <div className="startups-list__container">
      <div className="startups-list__header d-flex p-4 align-items-center justify-content-between">
        <h4 className="startups-list__header-title m-0 font-regular">
          ("Your Teams" |> str)
        </h4>
        <div className="startups-list__filter-btn-container">
          (
            switch (selectedStartupId) {
            | None => ReasonReact.null
            | Some(_id) =>
              <button
                className="startups-list__clear-filter-btn p-0"
                onClick=(_event => clearStartupCB())>
                ("Show All" |> str)
              </button>
            }
          )
        </div>
      </div>
      (
        startups
        |> List.map(startup => {
             let buttonClasses =
               switch (selectedStartupId) {
               | None => "startups-list__item d-flex align-items-center"
               | Some(id) =>
                 id == (startup |> Startup.id) ?
                   "startups-list__item d-flex align-items-center startups-list__item--selected" :
                   "startups-list__item d-flex align-items-center"
               };
             <a
              className=buttonClasses
              key=(startup |> Startup.name)
              onClick=(_event => selectStartupCB(startup |> Startup.id))>
              <span className="startups-list__item-dp"></span>
                <span className="startups-list__item-details d-flex flex-column px-3">
                  <span className="startups-list__item-name">
                    (startup |> Startup.name |> str)
                  </span>
                  <span className="startups-list__item-level">
                    ("Level: 1 Wireframing" |> str)
                  </span>
                </span>
             </a>;
           })
        |> Array.of_list
        |> ReasonReact.array
      )
    </div>,
};