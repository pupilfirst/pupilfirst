[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

let str = React.string;

[@react.component]
let make =
    (
      ~target,
      ~contentBlocks,
      ~updateContentBlockDeletionCB,
      ~authenticityToken,
    ) => {
  let (targetContentBlocks, updateTargetContentBlocks) =
    React.useState(() =>
      contentBlocks
      |> List.map(cb =>
           (
             cb |> ContentBlock.sortIndex,
             cb |> ContentBlock.blockType,
             Some(cb),
             cb |> ContentBlock.id,
           )
         )
    );
  let removeTargetContentCB = (contentBlockId, sortIndex) => {
    switch (contentBlockId) {
    | Some(contentBlockId) =>
      updateTargetContentBlocks(_ =>
        targetContentBlocks
        |> List.filter(((index, _, _, _)) => sortIndex != index)
      );
      updateContentBlockDeletionCB(contentBlockId);
    | None =>
      updateTargetContentBlocks(_ =>
        targetContentBlocks
        |> List.filter(((index, _, _, _)) => sortIndex != index)
      )
    };
    ();
  };

  let sortedContentBlocks =
    targetContentBlocks
    |> List.sort((x, y) => {
         let (x, _, _, _) = x;
         let (y, _, _, _) = y;
         x - y;
       });

  let newContentBlockCB = (sortIndex, blockType: ContentBlock.blockType) =>
    updateTargetContentBlocks(targetContentBlocks => {
      let (lowerCBs, upperCBs) =
        targetContentBlocks
        |> List.partition(((index, _, _, _)) => index < sortIndex);
      let newComponentKey = Js.Date.now() |> Js.Float.toString;
      let updatedUpperCBs =
        upperCBs
        |> List.map(((index, blockType, cb, id)) =>
             (index + 1, blockType, cb, id)
           )
        |> List.append([(sortIndex, blockType, None, newComponentKey)]);
      List.append(lowerCBs, updatedUpperCBs);
    });

  let moveContentUpCB = sortIndex => {
    let (lowerCBs, upperCBs) =
      sortedContentBlocks
      |> List.partition(((index, _, _, _)) => index < sortIndex);
    let currentCB = upperCBs |> List.hd;
    let contentBlockToSwap = lowerCBs |> List.rev |> List.hd;
    let (sortIndex1, blockType1, cb1, id1) = contentBlockToSwap;
    let (sortIndex2, blockType2, cb2, id2) = currentCB;
    let updatedlowerCBs =
      lowerCBs
      |> List.rev
      |> List.tl
      |> List.append([(sortIndex1, blockType2, cb2, id2)]);
    let updatedUpperCBs =
      upperCBs
      |> List.tl
      |> List.append([(sortIndex2, blockType1, cb1, id1)]);
    updateTargetContentBlocks(_ =>
      List.append(updatedlowerCBs, updatedUpperCBs)
    );
  };

  let moveContentDownCB = sortIndex => {
    let (lowerCBs, upperCBs) =
      sortedContentBlocks
      |> List.partition(((index, _, _, _)) => index <= sortIndex);
    let currentCB = lowerCBs |> List.rev |> List.hd;
    let contentBlockToSwap = upperCBs |> List.hd;
    let (sortIndex1, blockType1, cb1, id1) = contentBlockToSwap;
    let (sortIndex2, blockType2, cb2, id2) = currentCB;
    let updatedlowerCBs =
      lowerCBs
      |> List.rev
      |> List.tl
      |> List.append([(sortIndex2, blockType1, cb1, id1)]);
    let updatedUpperCBs =
      upperCBs
      |> List.tl
      |> List.append([(sortIndex1, blockType2, cb2, id2)]);
    updateTargetContentBlocks(_ =>
      List.append(updatedlowerCBs, updatedUpperCBs)
    );
  };
  [|
    <CurriculumEditor__ContentTypePicker
      key="static-content-picker"
      sortIndex={
                  let (sortIndex, _, _, _) =
                    sortedContentBlocks |> List.rev |> List.hd;
                  sortIndex + 2;
                }
      staticMode=true
      newContentBlockCB
    />,
  |]
  |> Array.append(
       sortedContentBlocks
       |> List.map(((sortIndex, blockType, contentBlock, id)) =>
            <CurriculumEditor__ContentBlockEditor
              key=id
              target
              contentBlock
              removeTargetContentCB
              blockType
              sortIndex
              newContentBlockCB
              moveContentUpCB
              moveContentDownCB
              authenticityToken
            />
          )
       |> Array.of_list,
     )
  |> React.array;
};