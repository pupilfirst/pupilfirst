exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let str = ReasonReact.string;

type displayMode =
  | Form
  | Rubric;

type state = {
  evaluation: list(Grading.t),
  displayMode,
};

type action =
  | UpdateGrading(Grading.t)
  | ChangeView(displayMode);

let component = ReasonReact.reducerComponent("EvaluationForm");

let saveButtonClasses = evaluation =>
  "btn btn-secondary" ++ (evaluation |> Grading.pending ? " disabled" : "");

let handleResponseJSON = (te, markReviewedCB, json) =>
  switch (
    json
    |> Json.Decode.(field("error", nullable(string)))
    |> Js.Null.toOption
  ) {
  | Some(error) =>
    CoachDashboard__Notification.error("Something went wrong!", error)
  | None =>
    CoachDashboard__Notification.success(
      "Grading Recorded",
      "Submission reviewed and moved to completed",
    );
    te |> markReviewedCB;
  };

let sendReview = (state, te, markReviewedCB, authenticityToken) => {
  let payload = Js.Dict.empty();
  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  Js.Dict.set(
    payload,
    "evaluation",
    state.evaluation |> Json.Encode.(list(Grading.gradingEncoder)),
  );
  let id = te |> TimelineEvent.id |> string_of_int;
  Js.Promise.(
    Fetch.fetchWithInit(
      "/timeline_events/" ++ id ++ "/review",
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
         |> handleResponseJSON(
              te |> TimelineEvent.updateEvaluation(state.evaluation),
              markReviewedCB,
            )
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

let handleClick = (state, te, markReviewedCB, authenticityToken) =>
  state.evaluation |> Grading.pending ?
    () : sendReview(state, te, markReviewedCB, authenticityToken);

let make =
    (
      ~timelineEvent,
      ~gradeLabels,
      ~replaceTimelineEvent,
      ~authenticityToken,
      ~passGrade,
      ~coachName,
      _children,
    ) => {
  ...component,
  initialState: () => {
    evaluation: timelineEvent |> TimelineEvent.evaluation,
    displayMode: Form,
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateGrading(newGrading) =>
      let evaluation =
        state.evaluation
        |> List.map(oldGrading => {
             let oldGradingId = oldGrading |> Grading.criterionId;
             let newGradingId = newGrading |> Grading.criterionId;
             oldGradingId == newGradingId ? newGrading : oldGrading;
           });
      ReasonReact.Update({...state, evaluation});
    | ChangeView(displayMode) => ReasonReact.Update({...state, displayMode})
    },
  render: ({state, send}) =>
    switch (state.displayMode) {
    | Form =>
      <div className="d-flex flex-column w-100">
        <div
          className="timeline-event-card__review-box-header py-3 mb-3 d-flex justify-content-between">
          <h5 className="timeline-event-card__field-header font-bold my-0">
            {"Grading Sheet:" |> str}
          </h5>
          {
            switch (timelineEvent |> TimelineEvent.rubric) {
            | Some(_rubric) =>
              <div
                className="timeline-event-card__link"
                onClick=(_event => send(ChangeView(Rubric)))>
                {"View Rubric" |> str}
              </div>
            | None => ReasonReact.null
            }
          }
        </div>
        {
          state.evaluation
          |> List.map(grading =>
               <GradeBar.Jsx2
                 key={grading |> Grading.criterionId}
                 grading
                 gradeLabels
                 gradeSelectCB=(
                   newGrading => send(UpdateGrading(newGrading))
                 )
                 passGrade
               />
             )
          |> Array.of_list
          |> ReasonReact.array
        }
        <div className="grade-bar__save-container d-flex justify-content-end">
          <button
            className={saveButtonClasses(state.evaluation)}
            onClick=(
              _event => {
                let te =
                  timelineEvent |> TimelineEvent.updateEvaluator(coachName);
                handleClick(
                  state,
                  te,
                  replaceTimelineEvent,
                  authenticityToken,
                );
                ();
              }
            )>
            {"Save Grading" |> str}
          </button>
        </div>
      </div>
    | Rubric =>
      <div className="d-flex flex-column w-100">
        <div
          className="timeline-event-card__review-box-header py-3 mb-3 d-flex justify-content-between">
          <h5 className="timeline-event-card__field-header font-bold my-0">
            {"Rubric:" |> str}
          </h5>
        </div>
        <div className="timeline-event-card__rubric-box py-3 pl-3">
          {
            switch (timelineEvent |> TimelineEvent.rubric) {
            | Some(rubric) => rubric |> str
            | None => ReasonReact.null
            }
          }
        </div>
        <div
          className="timeline-event-card__link pl-3"
          onClick=(_event => send(ChangeView(Form)))>
          <i className="fa fa-chevron-left mr-2" />
          {"Back to Grading Sheet" |> str}
        </div>
      </div>
    },
};
