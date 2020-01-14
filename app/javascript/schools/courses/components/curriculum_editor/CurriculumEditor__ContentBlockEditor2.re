[@bs.config {jsx: 3}];

let str = React.string;

open CurriculumEditor__Types;

[@react.component]
let make =
    (~targetId, ~contentBlock, ~removeContentBlockCB, ~updateContentBlockCB) => {
  <div> {"Content Block Editor" |> str} </div>;
};
