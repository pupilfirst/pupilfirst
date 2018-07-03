[%bs.raw {|require("./TimelineEventCard.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventCard");

let make = (~timelineEvent, _children) => {
  ...component,
  render: _self =>
    <div className="timeline-event-card__container card">
      <div className="card-header d-flex">
        (timelineEvent |> TimelineEvent.title |> str)
        <div className="timeline-event-card__header-subtext ml-auto">
          (
            "Submitted at: "
            ++ (
              timelineEvent
              |> TimelineEvent.submittedAt
              |> DateTime.format(DateTime.DateAndTime)
            )
            |> str
          )
        </div>
      </div>
      <div className="card-body row">
        <div className="col-md-9">
          <h5 className="timeline-event-card__field-header mt-0">
            ("Description:" |> str)
          </h5>
          (timelineEvent |> TimelineEvent.description |> str)
          <h5 className="timeline-event-card__field-header">
            ("Event Date:" |> str)
          </h5>
          (
            timelineEvent
            |> TimelineEvent.submittedAt
            |> DateTime.format(DateTime.OnlyDate)
            |> str
          )
          <h5 className="timeline-event-card__field-header">
            ("Submitted by:" |> str)
          </h5>
          (
            (timelineEvent |> TimelineEvent.founderName)
            ++ " ("
            ++ (timelineEvent |> TimelineEvent.startupName)
            ++ ")"
            |> str
          )
          <h5 className="timeline-event-card__field-header">
            ("Links:" |> str)
          </h5>
        </div>
        <div className="col-md-3"> ("Preview as founder" |> str) </div>
      </div>
    </div>,
};