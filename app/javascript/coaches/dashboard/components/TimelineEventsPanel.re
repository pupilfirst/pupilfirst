[%bs.raw {|require("./TimelineEventsPanel.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventsPanel");

let startupFilter = (startupId, tes) =>
  switch (startupId) {
  | None => tes
  | Some(id) => tes |> TimelineEvent.forStartupId(id)
  };

let make =
    (
      ~timelineEvents,
      ~selectedStartupId,
      ~replaceTE_CB,
      ~authenticityToken,
      _children,
    ) => {
  ...component,
  render: _self =>
    <div className="timeline-events-panel__container pt-4">
      <h4 className="font-semibold pb-2"> ("Review Pending" |> str) </h4>
      <TimelineEventsList
        timelineEvents=(
          timelineEvents
          |> startupFilter(selectedStartupId)
          |> TimelineEvent.verificationPending
        )
        replaceTE_CB
        authenticityToken
      />
      <h4 className="font-semibold mt-5 pb-2"> ("Complete" |> str) </h4>
      <TimelineEventsList
        timelineEvents=(
          timelineEvents
          |> startupFilter(selectedStartupId)
          |> TimelineEvent.verificationComplete
        )
        replaceTE_CB
        authenticityToken
      />
    </div>,
};