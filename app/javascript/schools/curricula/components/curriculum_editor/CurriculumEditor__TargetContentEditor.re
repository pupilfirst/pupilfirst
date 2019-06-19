[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

let str = React.string;

[@react.component]
let make = (~target, ~contentBlocks, ~authenticityToken) => {
  let (targetContentBlocks, updateTargetContentBlocks) =
    React.useState(() =>
      contentBlocks
      |> List.map(cb =>
           (
             cb |> ContentBlock.sortIndex,
             cb |> ContentBlock.blockType,
             Some(cb),
           )
         )
    );
  let removeTargetContentCB = (contentBlockId, sortIndex) => {
    switch (contentBlockId) {
    | Some(contentBlockId) =>
      updateTargetContentBlocks(_ =>
        targetContentBlocks
        |> List.filter(((_, _, cb)) =>
             switch (cb) {
             | Some(cb) => ContentBlock.id(cb) != contentBlockId
             | None => true
             }
           )
      )
    | None =>
      updateTargetContentBlocks(_ =>
        targetContentBlocks
        |> List.filter(((index, _, _)) => sortIndex != index)
      )
    };
    ();
  };

  let sortedContentBlocks =
    targetContentBlocks
    |> List.sort((x, y) => {
         let (x, _, _) = x;
         let (y, _, _) = y;
         x - y;
       });

  let newContentBlockCB = (sortIndex, blockType: ContentBlock.blockType) =>
    updateTargetContentBlocks(targetContentBlocks => {
      let (lowerCBs, upperCBs) =
        targetContentBlocks
        |> List.partition(((index, _, _)) => index < sortIndex);
      let updatedUpperCBs =
        upperCBs
        |> List.map(((index, blockType, cb)) => (index + 1, blockType, cb))
        |> List.append([(sortIndex, blockType, None)]);
      List.append(lowerCBs, updatedUpperCBs);
    });

  [|
    <CurriculumEditor__ContentTypePicker
      sortIndex={
                  let (sortIndex, _, _) =
                    sortedContentBlocks |> List.rev |> List.hd;
                  sortIndex + 1;
                }
      staticMode=true
      newContentBlockCB
    />,
  |]
  |> Array.append(
       sortedContentBlocks
       |> List.map(((sortIndex, blockType, contentBlock)) =>
            <CurriculumEditor__ContentBlockEditor
              key={sortIndex + Random.int(99999) |> string_of_int}
              target
              contentBlock
              removeTargetContentCB
              blockType
              sortIndex
              newContentBlockCB
              authenticityToken
            />
          )
       |> Array.of_list,
     )
  |> React.array;
};