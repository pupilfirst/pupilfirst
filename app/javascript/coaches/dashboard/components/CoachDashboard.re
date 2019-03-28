[%bs.raw {|require("./CoachDashboard.scss")|}];

open CoachDashboard__Types;

type props = {
  founders: list(Founder.t),
  teams: list(Team.t),
  timelineEvents: list(TimelineEvent.t),
  morePendingSubmissionsAfter: option(string),
  moreReviewedSubmissionsAfter: option(string),
  authenticityToken: string,
  emptyIconUrl: string,
  notAcceptedIconUrl: string,
  verifiedIconUrl: string,
  gradeLabels: list(GradeLabel.t),
  passGrade: int,
  courseId: int,
};

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
               oldTE |> TimelineEvent.id == (newTE |> TimelineEvent.id) ?
                 newTE : oldTE
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
        <div className="col-md-3">
          <SidePanel
            teams
            founders
            selectedFounder={state.selectedFounder}
            selectFounderCB
            clearFounderCB
          />
        </div>
        <div className="col-md-9">
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
          />
        </div>
      </div>
    </div>;
  },
};

let decode = json =>
  Json.Decode.{
    founders: json |> field("founders", list(Founder.decode)),
    teams: json |> field("teams", list(Team.decode)),
    timelineEvents:
      json |> field("timelineEvents", list(TimelineEvent.decode)),
    morePendingSubmissionsAfter:
      json
      |> field("morePendingSubmissionsAfter", nullable(string))
      |> Js.Null.toOption,
    moreReviewedSubmissionsAfter:
      json
      |> field("moreReviewedSubmissionsAfter", nullable(string))
      |> Js.Null.toOption,
    authenticityToken: json |> field("authenticityToken", string),
    emptyIconUrl: json |> field("emptyIconUrl", string),
    notAcceptedIconUrl: json |> field("notAcceptedIconUrl", string),
    verifiedIconUrl: json |> field("verifiedIconUrl", string),
    gradeLabels: json |> field("gradeLabels", list(GradeLabel.decode)),
    passGrade: json |> field("passGrade", int),
    courseId: json |> field("courseId", int),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(
        ~founders=props.founders,
        ~teams=props.teams,
        ~timelineEvents=props.timelineEvents,
        ~morePendingSubmissionsAfter=props.morePendingSubmissionsAfter,
        ~moreReviewedSubmissionsAfter=props.moreReviewedSubmissionsAfter,
        ~authenticityToken=props.authenticityToken,
        ~emptyIconUrl=props.emptyIconUrl,
        ~notAcceptedIconUrl=props.notAcceptedIconUrl,
        ~verifiedIconUrl=props.verifiedIconUrl,
        ~gradeLabels=props.gradeLabels,
        ~passGrade=props.passGrade,
        ~courseId=props.courseId,
        [||],
      );
    },
  );