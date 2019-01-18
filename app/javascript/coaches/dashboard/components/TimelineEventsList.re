let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventsList");

let make =
    (
      ~timelineEvents,
      ~founders,
      ~replaceTimelineEvent,
      ~authenticityToken,
      ~notAcceptedIconUrl,
      ~verifiedIconUrl,
      ~gradeLabels,
      ~passGrade,
      ~emptyIconUrl,
      _children,
    ) => {
  ...component,
  render: _self =>
    <div className="timeline-events-list__container">
      (
        if (timelineEvents |> List.length == 0) {
          <div className="timeline-events-panel__empty-notice p-4 mb-3">
            <img src=emptyIconUrl className="timeline-events-panel__empty-icon mx-auto" />
            ("Nothing to show here!" |> str)
          </div>;
        } else {
          timelineEvents
          |> List.map(te =>
               <TimelineEventCard
                 key=(te |> TimelineEvent.id |> string_of_int)
                 timelineEvent=te
                 founders
                 replaceTimelineEvent
                 authenticityToken
                 notAcceptedIconUrl
                 verifiedIconUrl
                 gradeLabels
                 passGrade
               />
             )
          |> Array.of_list
          |> ReasonReact.array;
        }
      )
    </div>,
};
