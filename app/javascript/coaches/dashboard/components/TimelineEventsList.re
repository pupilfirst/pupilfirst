let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventsList");

let make = (~timelineEvents, ~markReviewedCB, ~authenticityToken, _children) => {
  ...component,
  render: _self =>
    <div className="timeline-events-list__container">
      (
        timelineEvents
        |> List.map(te =>
             <TimelineEventCard
               key=(te |> TimelineEvent.id |> string_of_int)
               timelineEvent=te
               markReviewedCB
               authenticityToken
             />
           )
        |> Array.of_list
        |> ReasonReact.array
      )
    </div>,
};