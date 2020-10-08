[%bs.raw {|require("./Countdown.css")|}];

let str = React.string;

type state = {
  seconds: int,
  timeoutId: option(Js.Global.timeoutId),
  reload: bool,
};

type action =
  | SetTimeout(Js.Global.timeoutId)
  | Decrement
  | ToggleRelaod
  | ResetTimer(int);

let reducer = (state, action) =>
  switch (action) {
  | ToggleRelaod => {...state, reload: !state.reload}
  | SetTimeout(timeoutId) => {...state, timeoutId: Some(timeoutId)}
  | Decrement => {...state, seconds: state.seconds - 1, reload: !state.reload}
  | ResetTimer(seconds) => {...state, seconds, reload: !state.reload}
  };

let percentage = (current, total) => {
  int_of_float(float_of_int(current) /. float_of_int(total) *. 100.00);
};

let doughnutChart = (color, current, total) => {
  <svg viewBox="0 0 36 36" className={"countdown__doughnut-chart " ++ color}>
    <path
      className="countdown__doughnut-chart-bg"
      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
    />
    <path
      className="countdown__doughnut-chart-stroke"
      strokeDasharray={string_of_int(percentage(current, total)) ++ ", 100"}
      d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
    />
    <text
      x="50%" y="58%" className="countdown__doughnut-chart-text font-semibold">
      {string_of_int(current) |> str}
    </text>
  </svg>;
};

let relaodTimer = (seconds, state, send, ()) => {
  state.timeoutId->Belt.Option.forEach(Js.Global.clearTimeout);
  state.seconds == 0 ? send(ResetTimer(seconds)) : send(Decrement);
};

let reload = (seconds, state, send, ()) => {
  let timeoutId =
    Js.Global.setTimeout(
      relaodTimer(seconds, state, send),
      state.timeoutId->Belt.Option.mapWithDefault(0, _ => 1000),
    );
  send(SetTimeout(timeoutId));
  None;
};

[@react.component]
let make = (~seconds, ~color="white") => {
  let (state, send) =
    React.useReducer(reducer, {seconds, timeoutId: None, reload: false});
  React.useEffect1(reload(seconds, state, send), [|state.reload|]);
  <div> {doughnutChart("pink", state.seconds, seconds)} </div>;
};
