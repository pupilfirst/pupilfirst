let str = ReasonReact.string;

type state = {grades: list(Grade.t)};

type action =
  | UpdateGrade(list(Grade.t));

let component = ReasonReact.reducerComponent("ReviewForm");

let make = (~evaluationCriteria, ~gradeLabels, _children) => {
  ...component,
  initialState: () => {grades: []},
  reducer: (action, state) =>
    switch (action) {
    | UpdateGrade(grades) => ReasonReact.Update({...state, grades})
    },
  render: _self =>
    <div className="d-flex flex-column">
      <h5 className="timeline-event-card__field-header font-semibold mt-0">
        ("Grading Sheet:" |> str)
      </h5>
      (
        evaluationCriteria
        |> List.map(criterion =>
             <div key=(criterion |> EvaluationCriterion.id |> string_of_int)>
               (criterion |> EvaluationCriterion.name |> str)
               <GradeBar gradeLabels />
             </div>
           )
        |> Array.of_list
        |> ReasonReact.array
      )
    </div>,
};