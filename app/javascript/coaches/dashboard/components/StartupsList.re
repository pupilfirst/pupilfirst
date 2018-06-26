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
    <div>
      <div> ("Your startups:" |> str) </div>
      (
        startups
        |> List.map(startup => {
             let buttonClasses =
               switch (selectedStartupId) {
               | None => "btn btn-secondary"
               | Some(id) =>
                 id == (startup |> Startup.id) ?
                   "btn btn-primary" : "btn btn-secondary"
               };
             <button
               className=buttonClasses
               key=(startup |> Startup.name)
               onClick=(_event => selectStartupCB(startup |> Startup.id))>
               ("Startup Name: " ++ (startup |> Startup.name) |> str)
             </button>;
           })
        |> Array.of_list
        |> ReasonReact.array
      )
      (
        switch (selectedStartupId) {
        | None => ReasonReact.null
        | Some(_id) =>
          <button onClick=(_event => clearStartupCB())>
            ("Clear Filter" |> str)
          </button>
        }
      )
    </div>,
};