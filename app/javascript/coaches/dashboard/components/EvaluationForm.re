let str = ReasonReact.string;

type state = {evaluation: list(Grading.t)};

type action =
  | UpdateEvaluation(list(Grading.t));

let component = ReasonReact.reducerComponent("EvaluationForm");

let make = (~evaluation, ~gradeLabels, _children) => {
  ...component,
  initialState: () => {evaluation: evaluation},
  reducer: (action, state) =>
    switch (action) {
    | UpdateEvaluation(evaluation) =>
      ReasonReact.Update({...state, evaluation})
    },
  render: _self =>
    <div className="d-flex flex-column w-100">
      <h5 className="timeline-event-card__field-header font-semibold mt-0">
        ("Grading Sheet:" |> str)
      </h5>
      (
        evaluation
        |> List.map(grading =>
             <GradeBar
               key=(grading |> Grading.criterionId |> string_of_int)
               grading
               gradeLabels
               gradeSelectCB=(() => ())
             />
           )
        |> Array.of_list
        |> ReasonReact.array
      )
    </div>,
};