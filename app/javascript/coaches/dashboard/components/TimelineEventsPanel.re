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

let loadMoreVisible =
    (selectedTab, morePendingSubmissionsAfter, moreReviewedSubmissionsAfter) =>
  switch (
    selectedTab,
    morePendingSubmissionsAfter,
    moreReviewedSubmissionsAfter,
  ) {
  | (PendingTab, Some(_), _) => true
  | (ReviewedTab, _, Some(_)) => true
  | (PendingTab, _, _) => false
  | (ReviewedTab, _, _) => false
  };

let handleResponseJSON =
    (
      state,
      morePendingSubmissionsAfter,
      moreReviewedSubmissionsAfter,
      appendTEsCB,
      json,
    ) =>
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
    let moreSubmissionsAfter =
      json
      |> Json.Decode.(field("moreSubmissionsAfter", nullable(string)))
      |> Js.Null.toOption;

    let (newMorePendingSubmissionsAfter, newMoreReviewedSubmissionsAfter) =
      switch (state.selectedTab) {
      | PendingTab => (moreSubmissionsAfter, moreReviewedSubmissionsAfter)
      | ReviewedTab => (morePendingSubmissionsAfter, moreSubmissionsAfter)
      };

    appendTEsCB(
      newTEs,
      newMorePendingSubmissionsAfter,
      newMoreReviewedSubmissionsAfter,
    );
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
      morePendingSubmissionsAfter,
      moreReviewedSubmissionsAfter,
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
                morePendingSubmissionsAfter,
                moreReviewedSubmissionsAfter,
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

let showingSubmissionsSince =
    (
      selectedTab,
      earliestPendingSubmissionDate,
      earliestReviewedSubmissionDate,
    ) =>
  switch (
    selectedTab,
    earliestPendingSubmissionDate,
    earliestReviewedSubmissionDate,
  ) {
  | (PendingTab, Some(date), _)
  | (ReviewedTab, _, Some(date)) =>
    Some(
      "Showing submissions since "
      ++ date
      ++ " - scroll to the bottom to load more.",
    )
  | (PendingTab, None, _) => None
  | (ReviewedTab, _, None) => None
  };

let emptyMessage =
    (
      selectedFounder,
      selectedTab,
      morePendingSubmissionsAfter,
      moreReviewedSubmissionsAfter,
    ) => {
  let reviewedDefaultMessage = "When you review submissions, they'll be shown in this section.";

  switch (selectedFounder, selectedTab, moreReviewedSubmissionsAfter) {
  | (None, ReviewedTab, Some(_date)) =>
    <p>
      {reviewedDefaultMessage |> str}
      <br />
      {" You can also load previously reviewed submissions." |> str}
    </p>

  | (None, ReviewedTab, None) => reviewedDefaultMessage |> str
  | (selectedFounder, selectedTab, moreReviewedSubmissionsAfter) =>
    let fromText =
      switch (selectedFounder) {
      | None => ""
      | Some(founder) => "from " ++ (founder |> Founder.name)
      };

    let partOne =
      "There are no "
      ++ tabAsString(selectedTab)
      ++ " submissions "
      ++ fromText;

    let earliestSubmissionDate =
      switch (
        selectedTab,
        morePendingSubmissionsAfter,
        moreReviewedSubmissionsAfter,
      ) {
      | (PendingTab, Some(date), _)
      | (ReviewedTab, _, Some(date)) => Some(date)
      | (PendingTab, _, _) => None
      | (ReviewedTab, _, _) => None
      };

    let partTwo =
      switch (earliestSubmissionDate) {
      | Some(date) => " since " ++ date ++ "."
      | None => "."
      };

    let partThree =
      loadMoreVisible(
        selectedTab,
        morePendingSubmissionsAfter,
        moreReviewedSubmissionsAfter,
      ) ?
        " Please try loading more." : "";

    partOne ++ partTwo ++ partThree |> str;
  };
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
      ~morePendingSubmissionsAfter,
      ~moreReviewedSubmissionsAfter,
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
        switch (
          filteredTimelineEvents |> ListUtils.isEmpty,
          showingSubmissionsSince(
            state.selectedTab,
            morePendingSubmissionsAfter,
            moreReviewedSubmissionsAfter,
          ),
        ) {
        | (false, Some(message)) =>
          <div className="alert alert-info"> {message |> str} </div>
        | (true, Some(_m)) => ReasonReact.null
        | (false, None)
        | (true, None) => ReasonReact.null
        }
      }
      {
        if (filteredTimelineEvents |> ListUtils.isEmpty) {
          <div className="timeline-events-panel__empty-notice p-4 mb-3">
            <img
              src=emptyIconUrl
              className="timeline-events-panel__empty-icon mx-auto"
            />
            {
              emptyMessage(
                selectedFounder,
                state.selectedTab,
                morePendingSubmissionsAfter,
                moreReviewedSubmissionsAfter,
              )
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
              morePendingSubmissionsAfter,
              moreReviewedSubmissionsAfter,
            )) {
          let buttonText =
            state.isLoadingMore ? "Loading..." : "Load earlier submissions";
          <button
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
                  morePendingSubmissionsAfter,
                  moreReviewedSubmissionsAfter,
                  appendTEsCB,
                  courseId,
                )
            }>
            <i className="fa fa-cloud-download mr-1" />
            {buttonText |> str}
          </button>;
        } else {
          ReasonReact.null;
        }
      }
    </div>;
  },
};