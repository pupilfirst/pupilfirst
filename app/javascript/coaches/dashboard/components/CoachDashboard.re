[%bs.raw {|require("./CoachDashboard.scss")|}];

type state = {
  selectedFounder: option(Founder.t),
  timelineEvents: list(TimelineEvent.t),
  morePendingSubmissionsAfter: option(string),
  moreReviewedSubmissionsAfter: option(string),
};

type action =
  | SelectFounder(Founder.t)
  | ClearFounder
  | ReplaceTE(TimelineEvent.t)
  | AppendTEs(list(TimelineEvent.t), option(string), option(string));

let component = ReasonReact.reducerComponent("CoachDashboard");

let make =
    (
      ~founders,
      ~teams,
      ~timelineEvents,
      ~morePendingSubmissionsAfter,
      ~moreReviewedSubmissionsAfter,
      ~authenticityToken,
      ~emptyIconUrl,
      ~notAcceptedIconUrl,
      ~verifiedIconUrl,
      ~gradeLabels,
      ~passGrade,
      ~courseId,
      ~coachName,
      _children,
    ) => {
  ...component,
  initialState: () => {
    selectedFounder: None,
    timelineEvents,
    morePendingSubmissionsAfter,
    moreReviewedSubmissionsAfter,
  },
  reducer: (action, state) =>
    switch (action) {
    | SelectFounder(founder) =>
      ReasonReact.Update({...state, selectedFounder: Some(founder)})
    | ClearFounder => ReasonReact.Update({...state, selectedFounder: None})
    | ReplaceTE(newTE) =>
      ReasonReact.Update({
        ...state,
        timelineEvents:
          state.timelineEvents
          |> List.map(oldTE =>
               oldTE |> TimelineEvent.id == (newTE |> TimelineEvent.id)
                 ? newTE : oldTE
             ),
      })
    | AppendTEs(
        newTEs,
        morePendingSubmissionsAfter,
        moreReviewedSubmissionsAfter,
      ) =>
      let timelineEvents = newTEs |> List.append(state.timelineEvents);
      ReasonReact.Update({
        ...state,
        timelineEvents,
        morePendingSubmissionsAfter,
        moreReviewedSubmissionsAfter,
      });
    },
  render: ({state, send}) => {
    let selectFounderCB = founder => send(SelectFounder(founder));
    let clearFounderCB = () => send(ClearFounder);
    let replaceTimelineEvent = te => send(ReplaceTE(te));
    let appendTEsCB =
        (tes, morePendingSubmissionsAfter, moreReviewedSubmissionsAfter) =>
      send(
        AppendTEs(
          tes,
          morePendingSubmissionsAfter,
          moreReviewedSubmissionsAfter,
        ),
      );
    <div className="coach-dashboard__container container">
      <div className="row">
        <div className="col-lg-3 d-none d-lg-block">
          <FoundersList
            teams
            founders
            selectedFounder={state.selectedFounder}
            selectFounderCB
            clearFounderCB
          />
        </div>
        <div className="col-lg-9">
          <TimelineEventsPanel
            timelineEvents={state.timelineEvents}
            morePendingSubmissionsAfter={state.morePendingSubmissionsAfter}
            moreReviewedSubmissionsAfter={state.moreReviewedSubmissionsAfter}
            appendTEsCB
            founders
            selectedFounder={state.selectedFounder}
            replaceTimelineEvent
            authenticityToken
            emptyIconUrl
            notAcceptedIconUrl
            verifiedIconUrl
            gradeLabels
            passGrade
            courseId
            coachName
          />
        </div>
      </div>
    </div>;
  },
};
