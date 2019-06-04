exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

[%bs.raw {|require("./TimelineEventCard.scss")|}];

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

let handleResponseJSON = (state, send, te, replaceTimelineEvent, json) =>
  switch (
    json
    |> Json.Decode.(field("error", nullable(string)))
    |> Js.Null.toOption
  ) {
  | Some(error) =>
    CoachDashboard__Notification.error("Something went wrong!", error)
  | None =>
    CoachDashboard__Notification.success(
      "Feedback Sent",
      "Your feedback has been recorded and emailed to the student(s)",
    );
    te
    |> TimelineEvent.updateFeedback(state.feedbackHTML)
    |> replaceTimelineEvent;
    clearFeedback(send, ());
  };

let sendFeedback =
    (state, send, te, replaceTimelineEvent, authenticityToken, _event) => {
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
    |> then_(json =>
         json
         |> handleResponseJSON(state, send, te, replaceTimelineEvent)
         |> resolve
       )
    |> catch(error =>
         (
           switch (error |> handleApiError) {
           | Some(code) =>
             CoachDashboard__Notification.error(
               code |> string_of_int,
               "Please try again",
             )
           | None =>
             CoachDashboard__Notification.error(
               "Something went wrong!",
               "Please try again",
             )
           }
         )
         |> resolve
       )
    |> ignore
  );
};

let component = ReasonReact.reducerComponent("FeedbackForm");

let make =
    (~timelineEvent, ~replaceTimelineEvent, ~authenticityToken, _children) => {
  ...component,
  initialState: () => {showForm: false, feedbackHTML: ""},
  reducer: (action, state) =>
    switch (action) {
    | ToggleForm => ReasonReact.Update({...state, showForm: !state.showForm})
    | UpdateFeedback(html) =>
      ReasonReact.Update({...state, feedbackHTML: html})
    },
  render: ({state, send}) => {
    let updateFeedbackCB = updateFeedback(send);
    let latestFeedback = timelineEvent |> TimelineEvent.latestFeedback;
    <div className="feedback-form__container mt-3 w-100">
      {
        switch (latestFeedback) {
        | None => ReasonReact.null
        | Some(feedback) =>
          <div className="timeline-event-card__field-box mx-3 mt-3 p-3">
            <h5 className="timeline-event-card__field-header font-bold mt-0">
              {"Latest Feedback Sent:" |> str}
            </h5>
            <div dangerouslySetInnerHTML={"__html": feedback} />
          </div>
        }
      }
      {
        if (state.showForm) {
          <div className="feedback-form__trix-container py-3">
            <TrixEditor onChange=updateFeedbackCB />
            <button
              className="btn btn-secondary mt-2 mr-2"
              onClick={
                sendFeedback(
                  state,
                  send,
                  timelineEvent,
                  replaceTimelineEvent,
                  authenticityToken,
                )
              }>
              <i className="fa fa-envelope mr-1" />
              {"Send" |> str}
            </button>
            <button
              className="btn btn-ghost-secondary mt-2"
              onClick={clearFeedback(send)}>
              {"Cancel" |> str}
            </button>
          </div>;
        } else {
          <button
            className="btn btn-link font-semibold feedback-form__button w-100 p-3"
            onClick={toggleForm(send)}>
            <i className="fa fa-envelope mr-1" />
            {
              switch (latestFeedback) {
              | None => "Email Feedback" |> str
              | Some(_feedback) => "Email New Feedback" |> str
              }
            }
          </button>;
        }
      }
    </div>;
  },
};