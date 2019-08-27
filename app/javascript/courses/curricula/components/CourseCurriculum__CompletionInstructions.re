[@bs.config {jsx: 3}];

let str = React.string;

open CoursesCurriculum__Types;

[@react.component]
let make = (~targetDetails) =>
  switch (targetDetails |> TargetDetails.completionInstructions) {
  | Some(completionInstructions) =>
    <div className="mt-4 bg-green-200 p-5 rounded-lg">
      <div>
        <i className="fas fa-info-circle" />
        <span className="ml-2 font-semibold text-lg">
          {"Completion Instructions" |> str}
        </span>
      </div>
      <div> {completionInstructions |> str} </div>
    </div>
  | None => React.null
  };
