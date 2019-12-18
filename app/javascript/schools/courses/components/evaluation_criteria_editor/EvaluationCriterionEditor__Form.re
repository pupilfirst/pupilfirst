[@bs.config {jsx: 3}];

let str = React.string;

open EvaluationCriteriaEditor__Types;

type state = {
  name: string,
  description: string,
  maxGrade: int,
  passGrade: int,
  selectedGrade: int,
  gradesAndLabels: array(GradesAndLabels.t),
};

[@react.component]
let make = (~evaluationCriterion) => {
  let (state, setState) =
    React.useState(() =>
      switch (evaluationCriterion) {
      | None => {
          name: "",
          description: "",
          maxGrade: 0,
          passGrade: 0,
          selectedGrade: 0,
          gradesAndLabels: [||],
        }
      | Some(ec) => {
          name: ec |> EvaluationCriterion.name,
          description: ec |> EvaluationCriterion.description,
          maxGrade: ec |> EvaluationCriterion.maxGrade,
          passGrade: ec |> EvaluationCriterion.passGrade,
          selectedGrade: 1,
          gradesAndLabels: ec |> EvaluationCriterion.gradesAndLabels,
        }
      }
    );
  <div>
    <div className="mx-8 pt-8">
      <h5 className="uppercase text-center border-b border-gray-400 pb-2">
        {(
           switch (evaluationCriterion) {
           | None => "Add Evaluation Criterion"
           | Some(ec) => ec |> EvaluationCriterion.name
           }
         )
         |> str}
      </h5>
      <DisablingCover disabled=false>
        <div key="evaluation-criterion-editor" className="mt-3">
          <div className="mt-5">
            <label
              className="inline-block tracking-wide text-xs font-semibold "
              htmlFor="name">
              {"Name" |> str}
            </label>
            <input
              className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
              id="name"
              type_="text"
              placeholder="Type course name here"
              maxLength=50
              value={state.name}
            />
            <School__InputGroupError
              message="Enter a valid name"
              active={state.name |> String.length < 1}
            />
          </div>
          <div className="mt-5">
            <label
              className="inline-block tracking-wide text-xs font-semibold "
              htmlFor="name">
              {"Description" |> str}
            </label>
            <input
              className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
              id="description"
              type_="text"
              placeholder="Type description for the evaluation criterion"
              maxLength=50
              value={state.description}
            />
            <School__InputGroupError
              message="Enter a valid description"
              active={state.description |> String.length < 1}
            />
          </div>
        </div>
      </DisablingCover>
    </div>
  </div>;
};
