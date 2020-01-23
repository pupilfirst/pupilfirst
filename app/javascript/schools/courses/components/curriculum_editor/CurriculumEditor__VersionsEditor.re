[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

let str = ReasonReact.string;

[@react.component]
let make = (~targetId) => {
  <div
    className="flex target-group__target-container border-t bg-white overflow-hidden items-center relative hover:bg-gray-100 hover:text-primary-500">
    {"Versions editor" |> str}
  </div>;
};
