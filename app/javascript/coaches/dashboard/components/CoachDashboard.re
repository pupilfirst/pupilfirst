[@bs.deriving abstract]
type jsProps = {
  coach: Coach.t,
  startups: array(Startup.t),
  timelineEvents: array(TimelineEvent.JsDecode.t),
};

type state = {
  selectedStartupId: option(int),
  timelineEvents: list(TimelineEvent.t),
};

type action =
  | SelectStartup(int);

let component = ReasonReact.reducerComponent("CoachDashboard");

let make = (~coach, ~startups, ~timelineEvents, _children) => {
  ...component,
  initialState: () => {
    selectedStartupId: None,
    timelineEvents:
      timelineEvents
      |> Array.map(te => TimelineEvent.create(te))
      |> Array.to_list,
  },
  reducer: (action, state) =>
    switch (action) {
    | SelectStartup(id) =>
      ReasonReact.Update({...state, selectedStartupId: Some(id)})
    },
  render: ({state, send}) =>
    <div>
      (ReasonReact.string("Welcome Coach " ++ (coach |> Coach.name)))
      <StartupsList startups=(startups |> Array.to_list) appSend=send />
      <TimelineEventsPanel
        timelineEvents=state.timelineEvents
        selectedStartupId=state.selectedStartupId
      />
    </div>,
};

let jsComponent =
  ReasonReact.wrapReasonForJs(~component, jsProps =>
    make(
      ~coach=jsProps |. coach,
      ~startups=jsProps |. startups,
      ~timelineEvents=jsProps |. timelineEvents,
      [||],
    )
  );