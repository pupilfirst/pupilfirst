[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

let str = React.string;

[@react.component]
let make =
    (~target, ~contentBlocks, ~handleDeleteContentBlockCB, ~authenticityToken) => {
  let (contentBlocks, updateContentBlocks) =
    React.useState(() => contentBlocks);
  let removeTargetContentCB = contentBlockId => {
    updateContentBlocks(_ =>
      contentBlocks
      |> List.filter(cb => ContentBlock.id(cb) != contentBlockId)
    );
    handleDeleteContentBlockCB(contentBlockId);
  };

  contentBlocks
  |> List.map(contentBlock =>
       <CurriculumEditor__ContentBlockEditor
         target
         contentBlock={Some(contentBlock)}
         removeTargetContentCB
         blockType={contentBlock |> ContentBlock.blockType}
         authenticityToken
       />
     )
  |> Array.of_list
  |> React.array;
};