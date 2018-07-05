let str = ReasonReact.string;

type state = {te: TimelineEvent.t};

type action =
  | ChangeStatus(TimelineEvent.status);

let component = ReasonReact.reducerComponent("ReviewForm");

let saveStatus = (status, send, _event) => send(ChangeStatus(status));

let idPostfix = status =>
  switch (status) {
  | TimelineEvent.Verified(_) => "verified"
  | TimelineEvent.NeedsImprovement => "needs-improvement"
  | TimelineEvent.NotAccepted => "not-accepted"
  | TimelineEvent.Pending => "pending"
  };

let statusRadioInput = (status, timelineEventId, send) => {
  let inputId =
    "te-" ++ timelineEventId ++ "-statusRadio-" ++ (status |> idPostfix);
  <div className="form-check form-check-inline">
    <input
      className="form-check-input"
      type_="radio"
      name="statusRadioOptions"
      id=inputId
      onClick=(saveStatus(status, send))
    />
    <label className="form-check-label" htmlFor=inputId>
      (status |> TimelineEvent.statusString |> str)
    </label>
  </div>;
};

let gradeRadioInput = (grade, timelineEventId, send) => {
  let inputId =
    "te-"
    ++ timelineEventId
    ++ "-gradeRadio-"
    ++ (grade |> TimelineEvent.gradeString);
  <div className="form-check form-check-inline">
    <input
      className="form-check-input"
      type_="radio"
      name="gradeRadioOptions"
      id=inputId
      onClick=(saveStatus(TimelineEvent.Verified(grade), send))
    />
    <label className="form-check-label" htmlFor=inputId>
      (grade |> TimelineEvent.gradeString |> String.capitalize |> str)
    </label>
  </div>;
};

let make = (~timelineEvent, _children) => {
  ...component,
  initialState: () => {te: timelineEvent},
  reducer: (action, _state) =>
    switch (action) {
    | ChangeStatus(status) =>
      ReasonReact.Update({
        te: timelineEvent |> TimelineEvent.updateStatus(status),
      })
    },
  didUpdate: ({newSelf}) =>
    Js.log(
      "status: "
      ++ (
        newSelf.state.te |> TimelineEvent.status |> TimelineEvent.statusString
      ),
    ),
  render: ({state, send}) => {
    let timelineEventId = state.te |> TimelineEvent.id |> string_of_int;
    <div>
      <h5 className="timeline-event-card__field-header mt-0">
        ("Update Status:" |> str)
      </h5>
      <div>
        (
          statusRadioInput(
            TimelineEvent.Verified(TimelineEvent.Good),
            timelineEventId,
            send,
          )
        )
        (
          statusRadioInput(
            TimelineEvent.NeedsImprovement,
            timelineEventId,
            send,
          )
        )
        (statusRadioInput(TimelineEvent.NotAccepted, timelineEventId, send))
      </div>
      (
        if (state.te |> TimelineEvent.isVerified) {
          <div>
            <h5 className="timeline-event-card__field-header">
              ("Grade:" |> str)
            </h5>
            <div>
              (gradeRadioInput(TimelineEvent.Good, timelineEventId, send))
              (gradeRadioInput(TimelineEvent.Great, timelineEventId, send))
              (gradeRadioInput(TimelineEvent.Wow, timelineEventId, send))
            </div>
          </div>;
        } else {
          ReasonReact.null;
        }
      )
    </div>;
  },
};