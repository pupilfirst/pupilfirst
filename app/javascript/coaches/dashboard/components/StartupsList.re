let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("StartupsList");

let make = (~startups, ~selectStartupCB, ~clearStartupCB, _children) => {
  ...component,
  render: _self =>
    <div>
      <div> ("Your startups:" |> str) </div>
      (
        startups
        |> List.map(startup =>
             <button
               onClick=(_event => selectStartupCB(startup |> Startup.id))>
               ("Startup Name: " ++ (startup |> Startup.name) |> str)
             </button>
           )
        |> Array.of_list
        |> ReasonReact.array
      )
      <button onClick=(_event => clearStartupCB())>
        ("Clear Filter" |> str)
      </button>
    </div>,
};