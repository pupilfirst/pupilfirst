[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

let showGrades = gradeLabels =>
  <div className="inline-flex w-full text-center pr-4 mt-4">
    {
      gradeLabels
      |> Array.map(gradeLabel =>
           <div
             className="bg-gray-100 border py-1 px-4 text-sm cursor-pointer flex-1">
             {gradeLabel |> GradeLabel.grade |> string_of_int |> str}
           </div>
         )
      |> React.array
    }
  </div>;

[@react.component]
let make = (~gradeLabels, ~evaluvationCriteria, ~grades) =>
  <div className="p-4">
    <div className="font-semibold text-sm lg:text-base">
      {"Grade Card" |> str}
    </div>
    <div className="flex justify-between w-full pb-4">
      <div className="w-3/5">
        {showGrades(gradeLabels)}
        {showGrades(gradeLabels)}
        {showGrades(gradeLabels)}
      </div>
      <div
        className="w-2/5 items-center flex flex-col justify-center border-l">
        <i className="fas fa-marker text-6xl p-2 text-gray-600" />
        <div> {"Not Reviewed" |> str} </div>
      </div>
    </div>
  </div>;
