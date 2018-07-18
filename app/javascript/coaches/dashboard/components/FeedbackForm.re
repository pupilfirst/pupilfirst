module TrixEditor = {
  [@bs.deriving abstract]
  type jsProps = {onChange: string => unit};
  [@bs.module "../../../admin/components/eventsReviewDashboard/TrixEditor"]
  external jsTrixEditor : ReasonReact.reactClass = "default";
  let make = (~onChange, children) =>
    ReasonReact.wrapJsForReason(
      ~reactClass=jsTrixEditor,
      ~props=jsProps(~onChange),
      children,
    );
};

let str = ReasonReact.string;

type state = {
  showForm: bool,
  feedbackHTML: string,
};

type action =
  | ToggleForm
  | UpdateFeedback(string);

let toggleForm = (send, _event) => send(ToggleForm);

let updateFeedback = (send, html) => send(UpdateFeedback(html));

let cancelFeedback = (send, _event) => {
  send(UpdateFeedback(""));
  send(ToggleForm);
};

let sendFeedback = (state, send, _event) => {
  Js.log("Sending feedback for emailing");
  Js.log("Feedback to be sent:" ++ state.feedbackHTML);
  /* TODO: Send the feedback. */
  send(UpdateFeedback(""));
  send(ToggleForm);
};

let component = ReasonReact.reducerComponent("FeedbackForm");

let make = _children => {
  ...component,
  initialState: () => {showForm: false, feedbackHTML: ""},
  reducer: (action, state) =>
    switch (action) {
    | ToggleForm => ReasonReact.Update({...state, showForm: ! state.showForm})
    | UpdateFeedback(html) =>
      ReasonReact.Update({...state, feedbackHTML: html})
    },
  render: ({state, send}) => {
    let updateFeedbackCB = updateFeedback(send);
    <div className="feedback-form__container mt-2">
      (
        if (state.showForm) {
          <div className="feedback-form__trix-container">
            <TrixEditor onChange=updateFeedbackCB />
            <button
              className="btn btn-primary mt-1 mr-1"
              onClick=(sendFeedback(state, send))>
              <i className="fa fa-envelope mr-1" />
              ("Send" |> str)
            </button>
            <button
              className="btn btn-primary mt-1" onClick=(cancelFeedback(send))>
              ("Cancel" |> str)
            </button>
          </div>;
        } else {
          <button className="btn btn-primary mt-1" onClick=(toggleForm(send))>
            <i className="fa fa-envelope mr-1" />
            ("Email Feedback" |> str)
          </button>;
        }
      )
    </div>;
  },
  didUpdate: ({newSelf}) =>
    Js.log("feedbackhtml: " ++ newSelf.state.feedbackHTML),
};