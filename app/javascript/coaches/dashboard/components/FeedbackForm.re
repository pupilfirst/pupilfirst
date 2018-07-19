exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

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

let clearFeedback = (send, _event) => {
  send(UpdateFeedback(""));
  send(ToggleForm);
};

let handleResponseJSON = (send, json) =>
  switch (
    json
    |> Json.Decode.(field("error", nullable(string)))
    |> Js.Null.toOption
  ) {
  | Some(error) => Notification.error("Something went wrong!", error)
  | None =>
    Notification.success(
      "Feedback Sent",
      "Your feedback has been recorded and emailed to the student(s)",
    );
    clearFeedback(send, ());
  };

let sendFeedback = (state, send, te, authenticityToken, _event) => {
  Js.log("Sending feedback for emailing");
  Js.log("Feedback to be sent:" ++ state.feedbackHTML);
  let payload = Js.Dict.empty();
  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  Js.Dict.set(payload, "feedback", state.feedbackHTML |> Js.Json.string);
  let id = te |> TimelineEvent.id |> string_of_int;
  Js.Promise.(
    Fetch.fetchWithInit(
      "/timeline_events/" ++ id ++ "/send_feedback",
      Fetch.RequestInit.make(
        ~method_=Post,
        ~body=
          Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(payload))),
        ~headers=Fetch.HeadersInit.make({"Content-Type": "application/json"}),
        ~credentials=Fetch.SameOrigin,
        (),
      ),
    )
    |> then_(response =>
         if (Fetch.Response.ok(response)
             || Fetch.Response.status(response) == 422) {
           response |> Fetch.Response.json;
         } else {
           Js.Promise.reject(
             UnexpectedResponse(response |> Fetch.Response.status),
           );
         }
       )
    |> then_(json => json |> handleResponseJSON(send) |> resolve)
    |> catch(error =>
         (
           switch (error |> handleApiError) {
           | Some(code) =>
             Notification.error(code |> string_of_int, "Please try again")
           | None =>
             Notification.error("Something went wrong!", "Please try again")
           }
         )
         |> resolve
       )
    |> ignore
  );
};

let component = ReasonReact.reducerComponent("FeedbackForm");

let make = (~timelineEvent, ~authenticityToken, _children) => {
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
              onClick=(
                sendFeedback(state, send, timelineEvent, authenticityToken)
              )>
              <i className="fa fa-envelope mr-1" />
              ("Send" |> str)
            </button>
            <button
              className="btn btn-primary mt-1" onClick=(clearFeedback(send))>
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