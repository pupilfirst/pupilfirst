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

let handleResponseJSON = (te, replaceTE_CB, json) =>
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
    |> TimelineEvent.updateStatus(TimelineEvent.NotReviewed)
    |> replaceTE_CB;
  };

let undoReview = (te, replaceTE_CB, _event) => {
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
    |> then_(json => json |> handleResponseJSON(te, replaceTE_CB) |> resolve)
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

let make = (~timelineEvent, ~replaceTE_CB, _children) => {
  ...component,
  render: _self =>
    <button
      className="btn btn-primary undo-review-btn mt-1"
      onClick=(undoReview(timelineEvent, replaceTE_CB))>
      <i className="fa fa-undo mr-1" />
      ("Undo Review" |> str)
    </button>,
};