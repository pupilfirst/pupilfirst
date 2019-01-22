[%bs.raw {|require("./CoachDashboard.scss")|}];

type props = {
  coach: Coach.t,
  founders: list(Founder.t),
  teams: list(Team.t),
  timelineEvents: list(TimelineEvent.t),
  authenticityToken: string,
  emptyIconUrl: string,
  notAcceptedIconUrl: string,
  verifiedIconUrl: string,
  gradeLabels: list(GradeLabel.t),
  passGrade: int,
};

type state = {
  selectedFounderId: option(int),
  timelineEvents: list(TimelineEvent.t),
};

type action =
  | SelectFounder(int)
  | ClearFounder
  | ReplaceTE(TimelineEvent.t);

let component = ReasonReact.reducerComponent("CoachDashboard");

let make =
    (
      ~coach,
      ~founders,
      ~teams,
      ~timelineEvents,
      ~authenticityToken,
      ~emptyIconUrl,
      ~notAcceptedIconUrl,
      ~verifiedIconUrl,
      ~gradeLabels,
      ~passGrade,
      _children,
    ) => {
  ...component,
  initialState: () => {selectedFounderId: None, timelineEvents},
  reducer: (action, state) =>
    switch (action) {
    | SelectFounder(id) => ReasonReact.Update({...state, selectedFounderId: Some(id)})
    | ClearFounder => ReasonReact.Update({...state, selectedFounderId: None})
    | ReplaceTE(newTE) =>
      ReasonReact.Update({
        ...state,
        timelineEvents:
          state.timelineEvents
          |> List.map(oldTE => oldTE |> TimelineEvent.id == (newTE |> TimelineEvent.id) ? newTE : oldTE),
      })
    },
  render: ({state, send}) => {
    let selectFounderCB = id => send(SelectFounder(id));
    let clearFounderCB = () => send(ClearFounder);
    let replaceTimelineEvent = te => send(ReplaceTE(te));
    <div className="coach-dashboard__container container">
      <div className="row">
        <div className="col-md-4">
          {
            let pendingCount = state.timelineEvents |> TimelineEvent.reviewPending |> List.length;
            <SidePanel
              coach
              teams
              founders
              selectedFounderId=state.selectedFounderId
              selectFounderCB
              clearFounderCB
              pendingCount
            />;
          }
        </div>
        <div className="col-md-8">
          <TimelineEventsPanel
            timelineEvents=state.timelineEvents
            founders
            selectedFounderId=state.selectedFounderId
            replaceTimelineEvent
            authenticityToken
            emptyIconUrl
            notAcceptedIconUrl
            verifiedIconUrl
            gradeLabels
            passGrade
          />
        </div>
      </div>
    </div>;
  },
};

let decode = json =>
  Json.Decode.{
    coach: json |> field("coach", Coach.decode),
    founders: json |> field("founders", list(Founder.decode)),
    teams: json |> field("teams", list(Team.decode)),
    timelineEvents: json |> field("timelineEvents", list(TimelineEvent.decode)),
    authenticityToken: json |> field("authenticityToken", string),
    emptyIconUrl: json |> field("emptyIconUrl", string),
    notAcceptedIconUrl: json |> field("notAcceptedIconUrl", string),
    verifiedIconUrl: json |> field("verifiedIconUrl", string),
    gradeLabels: json |> field("gradeLabels", list(GradeLabel.decode)),
    passGrade: json |> field("passGrade", int),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(
        ~coach=props.coach,
        ~founders=props.founders,
        ~teams=props.teams,
        ~timelineEvents=props.timelineEvents,
        ~authenticityToken=props.authenticityToken,
        ~emptyIconUrl=props.emptyIconUrl,
        ~notAcceptedIconUrl=props.notAcceptedIconUrl,
        ~verifiedIconUrl=props.verifiedIconUrl,
        ~gradeLabels=props.gradeLabels,
        ~passGrade=props.passGrade,
        [||],
      );
    },
  );
