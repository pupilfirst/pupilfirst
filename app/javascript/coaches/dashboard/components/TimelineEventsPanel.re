[%bs.raw {|require("./TimelineEventsPanel.scss")|}];

let str = ReasonReact.string;

type activeTab =
  | Pending
  | Completed;

type state = {activeTab};

type action =
  | SwitchTab(activeTab);

let component = ReasonReact.reducerComponent("TimelineEventsPanel");

let startupfilter = (selectedStartupId, tes) =>
  switch (selectedStartupId) {
  | None => tes
  | Some(id) => tes |> List.filter(te => te |> TimelineEvent.startupId == id)
  };

let tabClass = (component, activeTab) =>
  "timeline-events-panel__tab-bar-item"
  ++ (
    activeTab == component ?
      " timeline-events-panel__tab-bar-item--active" : ""
  );

let make = (~timelineEvents, ~selectedStartupId, _children) => {
  ...component,
  initialState: () => {activeTab: Pending},
  reducer: (action, state) =>
    switch (action) {
    | SwitchTab(tab) => ReasonReact.Update({activeTab: tab})
    },
  render: ({state, send}) =>
    <div>
      <div
        className="timeline-events-panel__tab-bar d-flex justify-content-center">
        <button
          className=(tabClass(Pending, state.activeTab))
          onClick=(_event => send(SwitchTab(Pending)))>
          ("Pending" |> str)
        </button>
        <button
          className=(tabClass(Completed, state.activeTab))
          onClick=(_event => send(SwitchTab(Completed)))>
          ("Completed" |> str)
        </button>
      </div>
      <div className="timeline-events-panel__list-container mx-1">
        <div>
          (
            switch (selectedStartupId) {
            | None => "All TimelineEvents:" |> str
            | Some(id) =>
              "TimelineEvents for Startup "
              ++ string_of_int(id)
              ++ ": "
              |> str
            }
          )
          (
            timelineEvents
            |> startupfilter(selectedStartupId)
            |> List.map(timelineEvent =>
                 "Title: " ++ (timelineEvent |> TimelineEvent.title) |> str
               )
            |> Array.of_list
            |> ReasonReact.array
          )
        </div>
      </div>
    </div>,
};