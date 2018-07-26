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
      ~emptyIconUrl,
      _children,
    ) => {
  ...component,
  render: _self =>
    <div className="timeline-events-panel__container pt-4">
      <h4 className="font-semibold pb-2"> ("Review Pending" |> str) </h4>
      {
        let pendingTEs =
          timelineEvents
          |> startupFilter(selectedStartupId)
          |> TimelineEvent.verificationPending;
        if (pendingTEs |> List.length == 0) {
          <div className="timeline-events-panel__empty-notice">
            <img
              src=emptyIconUrl
              className="timeline-events-panel__empty-icon"
            />
            ("Nothing pending here!" |> str)
          </div>;
        } else {
          <TimelineEventsList
            timelineEvents=pendingTEs
            replaceTE_CB
            authenticityToken
          />;
        };
      }
      <h4 className="font-semibold mt-5 pb-2"> ("Complete" |> str) </h4>
      {
        let completeTEs =
          timelineEvents
          |> startupFilter(selectedStartupId)
          |> TimelineEvent.verificationComplete;
        if (completeTEs |> List.length == 0) {
          <div className="timeline-events-panel__empty-notice">
            <img
              src=emptyIconUrl
              className="timeline-events-panel__empty-icon"
            />
            ("Nothing to show!" |> str)
          </div>;
        } else {
          <TimelineEventsList
            timelineEvents=completeTEs
            replaceTE_CB
            authenticityToken
          />;
        };
      }
    </div>,
};