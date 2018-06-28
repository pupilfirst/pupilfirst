let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventsList");

let make = (~timelineEvents, _children) => {
  ...component,
  render: _self =>
    <div className="timeline-events-list__container">
      (
        timelineEvents
        |> List.map(te => <TimelineEventCard timelineEvent=te />)
        |> Array.of_list
        |> ReasonReact.array
      )
    </div>,
};