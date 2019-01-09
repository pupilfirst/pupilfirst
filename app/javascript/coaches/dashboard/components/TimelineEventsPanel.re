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
      ~replaceTimelineEvent,
      ~authenticityToken,
      ~emptyIconUrl,
      ~notAcceptedIconUrl,
      ~verifiedIconUrl,
      ~gradeLabels,
      ~passGrade,
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
          |> TimelineEvent.reviewPending;
        if (pendingTEs |> List.length == 0) {
          <div className="timeline-events-panel__empty-notice p-4 mb-3">
            <img
              src=emptyIconUrl
              className="timeline-events-panel__empty-icon mx-auto"
            />
            ("Nothing pending here!" |> str)
          </div>;
        } else {
          <TimelineEventsList
            timelineEvents=pendingTEs
            replaceTimelineEvent
            authenticityToken
            notAcceptedIconUrl
            verifiedIconUrl
            gradeLabels
            passGrade
          />;
        };
      }
      <h4 className="font-semibold mt-5 pb-2"> ("Complete" |> str) </h4>
      {
        let completeTEs =
          timelineEvents
          |> startupFilter(selectedStartupId)
          |> TimelineEvent.reviewComplete;
        if (completeTEs |> List.length == 0) {
          <div className="timeline-events-panel__empty-notice p-4 mb-3">
            <img
              src=emptyIconUrl
              className="timeline-events-panel__empty-icon mx-auto"
            />
            ("Nothing to show!" |> str)
          </div>;
        } else {
          <TimelineEventsList
            timelineEvents=completeTEs
            replaceTimelineEvent
            authenticityToken
            notAcceptedIconUrl
            verifiedIconUrl
            gradeLabels
            passGrade
          />;
        };
      }
    </div>,
};