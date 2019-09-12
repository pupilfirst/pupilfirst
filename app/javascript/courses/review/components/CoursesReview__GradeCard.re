[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

let renderGrades = gradeLabels =>
  <div className="flex px-4 text-center">
    {
      gradeLabels
      |> List.map(gradeLabel =>
           <div className="bg-gray-100 border py-2 px-4 cursor-pointer flex-1">
             {gradeLabel |> GradeLabel.grade |> string_of_int |> str}
           </div>
         )
      |> Array.of_list
      |> React.array
    }
  </div>;

[@react.component]
let make = (~authenticityToken, ~gradeLabels) =>
  <div className="mt-2 p-6">
    <div className="font-semibold text-lg"> {"Grade Card" |> str} </div>
    <div className="flex justify-between w-full py-4">
      <div className="w-2/3"> {renderGrades(gradeLabels)} </div>
      <div className="w-1/3  items-center flex flex-col border-l-2">
        <i className="fas fa-pen-alt text-6xl p-2 text-gray-600" />
        <div> {"Not Reviewed" |> str} </div>
      </div>
    </div>
  </div>;
