[%bs.raw {|require("./TimelineEventsPanel.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventsPanel");

let founderFilter = (founderId, tes) =>
  switch (founderId) {
  | None => tes
  | Some(id) => tes |> TimelineEvent.forFounderId(id)
  };

let make =
    (
      ~timelineEvents,
      ~hasMorePendingTEs,
      ~hasMoreCompletedTEs,
      ~loadMoreEventsCB,
      ~founders,
      ~selectedFounderId,
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
      <ul className="nav nav-tabs">
        <li className="nav-item"> <div className="nav-link active"> ("Pending" |> str) </div> </li>
        <li className="nav-item"> <div className="nav-link"> ("Complete" |> str) </div> </li>
      </ul>
      {
        let pendingTEs = timelineEvents |> founderFilter(selectedFounderId) |> TimelineEvent.reviewPending;
        let loadMoreCB = (tes, hasMorePendingTEs) => loadMoreEventsCB(tes, hasMorePendingTEs, hasMoreCompletedTEs);
        if (pendingTEs |> List.length == 0) {
          <div className="timeline-events-panel__empty-notice p-4 mb-3">
            <img src=emptyIconUrl className="timeline-events-panel__empty-icon mx-auto" />
            ("Nothing pending here!" |> str)
          </div>;
        } else {
          <TimelineEventsList
            timelineEvents=pendingTEs
            hasMoreEvents=hasMorePendingTEs
            loadMoreCB
            founders
            replaceTimelineEvent
            authenticityToken
            notAcceptedIconUrl
            verifiedIconUrl
            gradeLabels
            passGrade
          />;
        };
      }
      /*<h4 className="font-semibold mt-5 pb-2"> ("Complete" |> str) </h4>*/
      /*{*/
        /*let completeTEs = timelineEvents |> founderFilter(selectedFounderId) |> TimelineEvent.reviewComplete;*/
        /*if (completeTEs |> List.length == 0) {*/
          /*<div className="timeline-events-panel__empty-notice p-4 mb-3">*/
            /*<img src=emptyIconUrl className="timeline-events-panel__empty-icon mx-auto" />*/
            /*("Nothing to show!" |> str)*/
          /*</div>;*/
        /*} else {*/
          /*<TimelineEventsList*/
            /*timelineEvents=completeTEs*/
            /*founders*/
            /*replaceTimelineEvent*/
            /*authenticityToken*/
            /*notAcceptedIconUrl*/
            /*verifiedIconUrl*/
            /*gradeLabels*/
            /*passGrade*/
          /*/>;*/
        /*};*/
      /*}*/
    </div>,
};
