[%bs.raw {|require("./TimelineEventsPanel.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventsPanel");

let startupFilter = (startupId, tes) =>
  switch (startupId) {
  | None => tes
  | Some(id) => tes |> TimelineEvent.forStartupId(id)
  };

let make =
    (~timelineEvents, ~selectedStartupId, ~authenticityToken, _children) => {
  ...component,
  render: _self =>
    <div className="timeline-events-panel__container">
      <h3> ("Pending" |> str) </h3>
      <hr />
      <TimelineEventsList
        timelineEvents=(
          timelineEvents
          |> startupFilter(selectedStartupId)
          |> TimelineEvent.verificationPending
        )
        authenticityToken
      />
      <h3> ("Complete" |> str) </h3>
      <hr />
      <TimelineEventsList
        timelineEvents=(
          timelineEvents
          |> startupFilter(selectedStartupId)
          |> TimelineEvent.verificationComplete
        )
        authenticityToken
      />
    </div>,
};