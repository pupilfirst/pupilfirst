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
      (
        startups
        |> List.map(startup => {
             let buttonClasses =
               switch (selectedStartupId) {
               | None => "startups-list__item"
               | Some(id) =>
                 id == (startup |> Startup.id) ?
                   "startups-list__item startups-list__item--selected" :
                   "startups-list__item"
               };
             <button
               className=buttonClasses
               key=(startup |> Startup.name)
               onClick=(_event => selectStartupCB(startup |> Startup.id))>
               (startup |> Startup.name |> str)
             </button>;
           })
        |> Array.of_list
        |> ReasonReact.array
      )
      (
        switch (selectedStartupId) {
        | None => ReasonReact.null
        | Some(_id) =>
          <button
            className="startups-list__clear-filter-btn"
            onClick=(_event => clearStartupCB())>
            ("Show All" |> str)
          </button>
        }
      )
    </div>,
};