let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("StartupsList");

let make = (~startups, ~appSend, _children) => {
  ...component,
  render: _self =>
    <div>
      <div> (ReasonReact.string("Your startups:")) </div>
      (
        startups
        |> List.map(startup =>
             "Startup Name: " ++ (startup |> Startup.name) |> str
           )
        |> Array.of_list
        |> ReasonReact.arrayToElement
      )
    </div>,
};