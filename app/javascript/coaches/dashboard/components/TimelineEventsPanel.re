exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

[%bs.raw {|require("./TimelineEventsPanel.scss")|}];

let str = ReasonReact.string;

type selectedTab =
  | PendingTab
  | ReviewedTab;

type state = {
  selectedTab,
  isLoadingMore: bool,
};

type action =
  | SwitchTab(selectedTab)
  | UpdateLoading(bool);

let component = ReasonReact.reducerComponent("TimelineEventsPanel");

let founderFilter = (founder, tes) =>
  switch (founder) {
  | None => tes
  | Some(founder) => tes |> TimelineEvent.forFounder(founder)
  };

let loadMoreVisible = (selectedTab, hasMorePendingTEs, hasMoreCompletedTEs) =>
  switch (selectedTab) {
  | PendingTab => hasMorePendingTEs
  | ReviewedTab => hasMoreCompletedTEs
  };

let handleResponseJSON =
    (state, hasMorePendingTEs, hasMoreCompletedTEs, appendTEsCB, json) =>
  switch (
    json
    |> Json.Decode.(field("error", nullable(string)))
    |> Js.Null.toOption
  ) {
  | Some(error) =>
    CoachDashboard__Notification.error("Something went wrong!", error)
  | None =>
    let newTEs =
      json
      |> Json.Decode.(field("timelineEvents", list(TimelineEvent.decode)));
    let moreToLoad = json |> Json.Decode.(field("moreToLoad", bool));

    let (newHasMorePendingTEs, newHasMoreCompletedTEs) =
      switch (state.selectedTab) {
      | PendingTab => (moreToLoad, hasMoreCompletedTEs)
      | ReviewedTab => (hasMorePendingTEs, moreToLoad)
      };

    appendTEsCB(newTEs, newHasMorePendingTEs, newHasMoreCompletedTEs);
  };

let tabAsString = tab =>
  switch (tab) {
  | PendingTab => "pending"
  | ReviewedTab => "reviewed"
  };

let fetchEvents =
    (
      state,
      send,
      tes,
      hasMorePendingTEs,
      hasMoreCompletedTEs,
      appendTEsCB,
      courseId,
    ) => {
  send(UpdateLoading(true));
  let excludedIds =
    tes
    |> List.map(te => te |> TimelineEvent.id |> string_of_int)
    |> String.concat("&excludedIds[]=");
  let reviewStatus = tabAsString(state.selectedTab);
  let params =
    "limit=20&reviewStatus="
    ++ reviewStatus
    ++ "&excludedIds[]="
    ++ excludedIds;
  Js.Promise.(
    Fetch.fetch(
      "/courses/"
      ++ (courseId |> string_of_int)
      ++ "/coach_dashboard/timeline_events?"
      ++ params,
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
         {
           json
           |> handleResponseJSON(
                state,
                hasMorePendingTEs,
                hasMoreCompletedTEs,
                appendTEsCB,
              );
           send(UpdateLoading(false));
         }
         |> resolve
       )
    |> catch(error =>
         {
           switch (error |> handleApiError) {
           | Some(code) =>
             CoachDashboard__Notification.error(
               code |> string_of_int,
               "Please try again",
             )
           | None =>
             CoachDashboard__Notification.error(
               "Something went wrong",
               "Please try again",
             )
           };
           send(UpdateLoading(false));
         }
         |> resolve
       )
    |> ignore
  );
};

let emptyMessage =
    (selectedFounder, selectedTab, hasMorePendingTEs, hasMoreCompletedTEs) => {
  let (fromText, clearFilterText) =
    switch (selectedFounder) {
    | None => ("", "")
    | Some(founder) => (
        "from " ++ (founder |> Founder.name),
        "clear filter and ",
      )
    };
  "There are no "
  ++ tabAsString(PendingTab)
  ++ " submissions "
  ++ fromText
  ++ " in the list."
  ++ (
    loadMoreVisible(selectedTab, hasMorePendingTEs, hasMoreCompletedTEs) ?
      " Please " ++ clearFilterText ++ "try loading more." : ""
  );
};

let pendingTabClasses = selectedTab => {
  let classes = "timeline-events-panel__status-tab";
  switch (selectedTab) {
  | PendingTab => classes ++ " timeline-events-panel__status-tab--active"
  | ReviewedTab => classes
  };
};

let reviewedTabClasses = selectedTab => {
  let classes = "timeline-events-panel__status-tab";
  switch (selectedTab) {
  | PendingTab => classes
  | ReviewedTab => classes ++ " timeline-events-panel__status-tab--active"
  };
};

let make =
    (
      ~timelineEvents,
      ~hasMorePendingTEs,
      ~hasMoreCompletedTEs,
      ~appendTEsCB,
      ~founders,
      ~selectedFounder,
      ~replaceTimelineEvent,
      ~authenticityToken,
      ~emptyIconUrl,
      ~notAcceptedIconUrl,
      ~verifiedIconUrl,
      ~gradeLabels,
      ~passGrade,
      ~courseId,
      _children,
    ) => {
  ...component,
  initialState: () => {selectedTab: PendingTab, isLoadingMore: false},
  reducer: (action, state) =>
    switch (action) {
    | SwitchTab(selectedTab) => ReasonReact.Update({...state, selectedTab})
    | UpdateLoading(isLoadingMore) =>
      ReasonReact.Update({...state, isLoadingMore})
    },
  render: ({state, send}) => {
    let statusFilter =
      switch (state.selectedTab) {
      | PendingTab => TimelineEvent.reviewPending
      | ReviewedTab => TimelineEvent.reviewComplete
      };
    let founderTimelineEvents =
      timelineEvents |> founderFilter(selectedFounder);
    let pendingCount =
      founderTimelineEvents |> TimelineEvent.reviewPending |> List.length;
    let filteredTimelineEvents = founderTimelineEvents |> statusFilter;
    <div className="pt-4">
      <div className="d-flex mb-3 timeline-events-panel__status-tab-container">
        <div
          className={pendingTabClasses(state.selectedTab)}
          onClick={_e => send(SwitchTab(PendingTab))}>
          {"Pending" |> str}
          {
            if (pendingCount > 0) {
              <div className="timeline-events-panel__status-tab-badge">
                {pendingCount |> string_of_int |> str}
              </div>;
            } else {
              ReasonReact.null;
            }
          }
        </div>
        <div
          className={reviewedTabClasses(state.selectedTab)}
          onClick={_e => send(SwitchTab(ReviewedTab))}>
          {"Reviewed" |> str}
        </div>
      </div>
      {
        if (filteredTimelineEvents |> List.length == 0) {
          <div className="timeline-events-panel__empty-notice p-4 mb-3">
            <img
              src=emptyIconUrl
              className="timeline-events-panel__empty-icon mx-auto"
            />
            {
              emptyMessage(
                selectedFounder,
                state.selectedTab,
                hasMorePendingTEs,
                hasMoreCompletedTEs,
              )
              |> str
            }
          </div>;
        } else {
          <TimelineEventsList
            timelineEvents=filteredTimelineEvents
            founders
            replaceTimelineEvent
            authenticityToken
            notAcceptedIconUrl
            verifiedIconUrl
            gradeLabels
            passGrade
          />;
        }
      }
      {
        if (loadMoreVisible(
              state.selectedTab,
              hasMorePendingTEs,
              hasMoreCompletedTEs,
            )) {
          let buttonText =
            state.isLoadingMore ? "Loading..." : "Load earlier submissions";
          <div
            className={
              "btn btn-primary mb-3"
              ++ (state.isLoadingMore ? " disabled" : "")
            }
            onClick={
              _e =>
                fetchEvents(
                  state,
                  send,
                  timelineEvents,
                  hasMorePendingTEs,
                  hasMoreCompletedTEs,
                  appendTEsCB,
                  courseId,
                )
            }>
            <i className="fa fa-cloud-download mr-1" />
            {buttonText |> str}
          </div>;
        } else {
          ReasonReact.null;
        }
      }
    </div>;
  },
};