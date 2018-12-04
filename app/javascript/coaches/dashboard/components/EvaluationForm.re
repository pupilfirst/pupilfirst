let str = ReasonReact.string;

type state = {evaluation: list(Grading.t)};

type action =
  | UpdateGrading(Grading.t);

let component = ReasonReact.reducerComponent("EvaluationForm");

let make = (~evaluation, ~gradeLabels, _children) => {
  ...component,
  initialState: () => {evaluation: evaluation},
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
      <h5 className="timeline-event-card__field-header font-semibold mt-0">
        ("Grading Sheet:" |> str)
      </h5>
      (
        state.evaluation
        |> List.map(grading =>
             <GradeBar
               key=(grading |> Grading.criterionId |> string_of_int)
               grading
               gradeLabels
               gradeSelectCB=(newGrading => send(UpdateGrading(newGrading)))
             />
           )
        |> Array.of_list
        |> ReasonReact.array
      )
    </div>,
};