let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventsList");

let emptyMessage = (selectedTabString, selectedFounder) => {
  let (fromText, clearFilterText) =
    switch (selectedFounder) {
    | None => ("", "")
    | Some(founder) => ("from " ++ (founder |> Founder.name), "clear filter and ")
    };
  "There are no "
  ++ selectedTabString
  ++ " submissions "
  ++ fromText
  ++ " in the list. Please "
  ++ clearFilterText
  ++ "try loading more.";
};

let make =
    (
      ~timelineEvents,
      ~founders,
      ~selectedFounder,
      ~selectedTabString,
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
            (emptyMessage(selectedTabString, selectedFounder) |> str)
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
