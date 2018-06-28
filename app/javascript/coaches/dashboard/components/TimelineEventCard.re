[%bs.raw {|require("./TimelineEventCard.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventCard");

let make = (~timelineEvent, _children) => {
  ...component,
  render: _self =>
    <div className="timeline-event-card__container card">
      <div className="card-header">
        (timelineEvent |> TimelineEvent.title |> str)
      </div>
      <div className="card-body">
        (timelineEvent |> TimelineEvent.description |> str)
      </div>
    </div>,
};