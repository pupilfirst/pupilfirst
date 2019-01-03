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
  | Some(error) => Js.log(error)
  | None =>
    Notification.success(
      "Review Reverted",
      "Review cleared and moved to pending",
    );
    te
    |> TimelineEvent.updateEvaluation(
         te |> TimelineEvent.evaluation |> Grading.clearedEvaluation,
       )
    |> replaceTimelineEvent;
  };

let undoReview = (te, replaceTimelineEvent, _event) => {
  let id = te |> TimelineEvent.id |> string_of_int;
  Js.Promise.(
    Fetch.fetchWithInit(
      "/timeline_events/" ++ id ++ "/undo_review",
      Fetch.RequestInit.make(
        ~method_=Post,
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

let make = (~timelineEvent, ~replaceTimelineEvent, _children) => {
  ...component,
  render: _self =>
    <div className="d-flex justify-content-end">
      <button
        className="btn btn-sm btn-default undo-review-btn"
        onClick=(undoReview(timelineEvent, replaceTimelineEvent))>
        <i className="fa fa-undo mr-1" />
        ("Undo Review" |> str)
      </button>
    </div>,
};