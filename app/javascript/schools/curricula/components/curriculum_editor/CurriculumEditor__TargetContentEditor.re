[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

let str = React.string;

[@react.component]
let make = (~target, ~contentBlocks, ~authenticityToken) => {
  let (contentBlocks, updateContentBlocks) =
    React.useState(() => contentBlocks);
  contentBlocks
  |> List.map(contentBlock =>
       <CurriculumEditor__ContentBlockEditor
         target
         contentBlock={Some(contentBlock)}
         blockType={contentBlock |> ContentBlock.blockType}
         authenticityToken
       />
     )
  |> Array.of_list
  |> React.array;
};