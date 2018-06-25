let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventsPanel");

let filter = (selectedStartupId, tes) =>
  switch (selectedStartupId) {
  | None => tes
  | Some(id) => tes |> List.filter(te => te |> TimelineEvent.startupId == id)
  };

let make = (~timelineEvents, ~selectedStartupId, _children) => {
  ...component,
  render: _self =>
    <div>
      <div> (ReasonReact.string("Timeline Events:")) </div>
      (
        timelineEvents
        |> filter(selectedStartupId)
        |> List.map(timelineEvent =>
             "Title: " ++ (timelineEvent |> TimelineEvent.title) |> str
           )
        |> Array.of_list
        |> ReasonReact.arrayToElement
      )
    </div>,
};