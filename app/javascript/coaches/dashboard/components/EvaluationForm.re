exception UnexpectedResponse(int);

let handleApiError =
  [@bs.open]
  (
    fun
    | UnexpectedResponse(code) => code
  );

let str = ReasonReact.string;

type state = {evaluation: list(Grading.t)};

type action =
  | UpdateGrading(Grading.t);

let component = ReasonReact.reducerComponent("EvaluationForm");

let saveButtonClasses = evaluation =>
  "btn btn-secondary" ++ (evaluation |> Grading.pending ? " disabled" : "");

let handleResponseJSON = (te, markReviewedCB, json) =>
  switch (
    json
    |> Json.Decode.(field("error", nullable(string)))
    |> Js.Null.toOption
  ) {
  | Some(error) => Notification.error("Something went wrong!", error)
  | None =>
    Notification.success(
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
      _children,
    ) => {
  ...component,
  initialState: () => {evaluation: timelineEvent |> TimelineEvent.evaluation},
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
    },
  render: ({state, send}) =>
    <div className="d-flex flex-column w-100">
      <div className="timeline-event-card__review-box-header py-3 mb-3">
        <h5 className="timeline-event-card__field-header font-bold my-0">
          ("Grading Sheet:" |> str)
        </h5>
      </div>
      (
        state.evaluation
        |> List.map(grading =>
             <GradeBar
               key=(grading |> Grading.criterionId |> string_of_int)
               grading
               gradeLabels
               gradeSelectCB=(newGrading => send(UpdateGrading(newGrading)))
               passGrade
             />
           )
        |> Array.of_list
        |> ReasonReact.array
      )
      <div className="d-flex justify-content-between">
        <button
          className=(saveButtonClasses(state.evaluation))
          onClick=(
            _event =>
              handleClick(
                state,
                timelineEvent,
                replaceTimelineEvent,
                authenticityToken,
              )
          )>
          ("Save Grading" |> str)
        </button>
      </div>
    </div>,
};