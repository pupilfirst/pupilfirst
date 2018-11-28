[%bs.raw {|require("./GradeBar.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("GradeBar");

let make = (~gradeLabels, ~gradeSelectCB=?, _children) => {
  ...component,
  render: _self =>
    <div className="btn-toolbar gradebar-container" role="toolbar">
      <div className="btn-group d-flex" role="group">
        (
          gradeLabels
          |> List.map(gradeLabel =>
               <button
                 type_="button" className="btn btn-secondary gradebar-button">
                 (gradeLabel |> GradeLabel.grade |> string_of_int |> str)
               </button>
             )
          |> Array.of_list
          |> ReasonReact.array
        )
      </div>
    </div>,
};