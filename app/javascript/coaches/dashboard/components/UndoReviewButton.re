[%bs.raw {|require("./UndoReviewButton.scss")|}];

exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("UndoReviewButton");

let handleResponseJSON = (te, replaceTimelineEvent, json) =>
  switch (
    json
    |> Json.Decode.(field("error", nullable(string)))
    |> Js.Null.toOption
  ) {
  | Some(error) =>
    CoachDashboard__Notification.error("Something went wrong!", error)
  | None =>
    CoachDashboard__Notification.success(
      "Review Reverted",
      "Review cleared and moved to pending",
    );
    te
    |> TimelineEvent.updateEvaluation(
         te |> TimelineEvent.evaluation |> Grading.clearedEvaluation,
       )
    |> replaceTimelineEvent;
  };

let undoReview = (te, replaceTimelineEvent, authenticityToken, _event) => {
  let id = te |> TimelineEvent.id |> string_of_int;
  let payload = Js.Dict.empty();
  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  Js.Promise.(
    Fetch.fetchWithInit(
      "/timeline_events/" ++ id ++ "/undo_review",
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
         json |> handleResponseJSON(te, replaceTimelineEvent) |> resolve
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

let make =
    (~timelineEvent, ~replaceTimelineEvent, ~authenticityToken, _children) => {
  ...component,
  render: _self =>
    <div className="d-flex justify-content-end">
      <button
        className="btn btn-sm btn-default undo-review-btn mx-0"
        onClick={
          undoReview(timelineEvent, replaceTimelineEvent, authenticityToken)
        }>
        <i className="fa fa-undo mr-1" />
        {"Undo Review" |> str}
      </button>
    </div>,
};