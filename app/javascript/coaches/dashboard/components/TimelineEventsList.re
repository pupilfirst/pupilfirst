exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventsList");

let handleResponseJSON = (loadMoreCB, json) =>
  switch (json |> Json.Decode.(field("error", nullable(string))) |> Js.Null.toOption) {
  | Some(error) => Notification.error("Something went wrong!", error)
  | None =>
    let newTEs = json |> Json.Decode.(field("timelineEvents", list(TimelineEvent.decode)));
    let moreToLoad = json |> Json.Decode.(field("moreToLoad", bool));
    loadMoreCB(newTEs, moreToLoad);
  };

let fetchEvents = (tes, loadMoreCB) => {
  Js.log("Loading more pending events...");
  let excludedIds =
    tes |> List.map(te => te |> TimelineEvent.id |> string_of_int) |> String.concat("&excludedIds[]=");
  let params = "limit=1&reviewStatus=pending&excludedIds[]=" ++ excludedIds;
  Js.Promise.(
    Fetch.fetch("/courses/3/coach_dashboard/timeline_events?" ++ params)
    |> then_(response =>
         if (Fetch.Response.ok(response) || Fetch.Response.status(response) == 422) {
           response |> Fetch.Response.json;
         } else {
           Js.Promise.reject(UnexpectedResponse(response |> Fetch.Response.status));
         }
       )
    |> then_(json => json |> handleResponseJSON(loadMoreCB) |> resolve)
    |> catch(error =>
         (
           switch (error |> handleApiError) {
           | Some(code) => Notification.error(code |> string_of_int, "Please try again")
           | None => Notification.error("Something went wrong", "Please try again")
           }
         )
         |> resolve
       )
    |> ignore
  );
};

let make =
    (
      ~timelineEvents,
      ~hasMoreEvents,
      ~loadMoreCB,
      ~founders,
      ~replaceTimelineEvent,
      ~authenticityToken,
      ~notAcceptedIconUrl,
      ~verifiedIconUrl,
      ~gradeLabels,
      ~passGrade,
      _children,
    ) => {
  ...component,
  render: _self =>
    <div className="timeline-events-list__container">
      (
        timelineEvents
        |> List.map(te =>
             <TimelineEventCard
               key=(te |> TimelineEvent.id |> string_of_int)
               timelineEvent=te
               founders
               replaceTimelineEvent
               authenticityToken
               notAcceptedIconUrl
               verifiedIconUrl
               gradeLabels
               passGrade
             />
           )
        |> Array.of_list
        |> ReasonReact.array
      )
      (
        if (hasMoreEvents) {
          <div className="btn btn-primary" onClick=(_e => fetchEvents(timelineEvents, loadMoreCB))>
            <i className="fa fa-cloud-download mr-1" />
            ("Load more" |> str)
          </div>;
        } else {
          ReasonReact.null;
        }
      )
    </div>,
};
