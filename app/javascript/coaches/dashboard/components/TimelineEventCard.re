[%bs.raw {|require("./TimelineEventCard.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventCard");

[@bs.val] [@bs.module "date-fns"]
external dateFormat : (string, string) => string = "format";

let make = (~timelineEvent, _children) => {
  ...component,
  render: _self =>
    <div className="timeline-event-card__container card">
      <div className="card-header d-flex">
        (timelineEvent |> TimelineEvent.title |> str)
        <div className="ml-auto">
          (
            dateFormat(timelineEvent |> TimelineEvent.eventOn, "Do MMM YYYY")
            |> str
          )
        </div>
      </div>
      <div className="card-body">
        (timelineEvent |> TimelineEvent.description |> str)
      </div>
    </div>,
};