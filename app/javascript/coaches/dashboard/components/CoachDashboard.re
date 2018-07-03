[%bs.raw {|require("./CoachDashboard.scss")|}];

type props = {
  coach: Coach.t,
  startups: list(Startup.t),
  timelineEvents: list(TimelineEvent.t),
};

type state = {
  selectedStartupId: option(int),
  timelineEvents: list(TimelineEvent.t),
};

type action =
  | SelectStartup(int)
  | ClearStartup;

let component = ReasonReact.reducerComponent("CoachDashboard");

let make = (~coach, ~startups, ~timelineEvents, _children) => {
  ...component,
  initialState: () => {selectedStartupId: None, timelineEvents},
  reducer: (action, state) =>
    switch (action) {
    | SelectStartup(id) =>
      ReasonReact.Update({...state, selectedStartupId: Some(id)})
    | ClearStartup => ReasonReact.Update({...state, selectedStartupId: None})
    },
  render: ({state, send}) => {
    let selectStartupCB = id => send(SelectStartup(id));
    let clearStartupCB = () => send(ClearStartup);
    <div className="coach-dashboard__container">
      <div className="row">
        <div className="col-md-3">
          <SidePanel
            coach
            startups
            selectedStartupId=state.selectedStartupId
            selectStartupCB
            clearStartupCB
          />
        </div>
        <div className="col">
          <TimelineEventsPanel
            timelineEvents=state.timelineEvents
            selectedStartupId=state.selectedStartupId
          />
        </div>
      </div>
    </div>;
  },
};

let decode = json =>
  Json.Decode.{
    coach: json |> field("coach", Coach.decode),
    startups: json |> field("startups", list(Startup.decode)),
    timelineEvents:
      json |> field("timelineEvents", list(TimelineEvent.decode)),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(
        ~coach=props.coach,
        ~startups=props.startups,
        ~timelineEvents=props.timelineEvents,
        [||],
      );
    },
  );