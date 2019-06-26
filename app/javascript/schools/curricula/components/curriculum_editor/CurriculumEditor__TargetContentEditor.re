[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

let str = React.string;

module SortContentBlockMutation = [%graphql
  {|
   mutation($contentBlockIds: [ID!]!) {
    sortContentBlocks(contentBlockIds: $contentBlockIds) {
       success
     }
   }
   |}
];

let updateContentBlockSorting =
    (
      contentBlocks,
      authenticityToken,
      sortContentBlock,
      toggleSortContentBlock,
      (),
    ) => {
  let contentBlockIds =
    contentBlocks
    |> List.map(((_, _, cb, id)) =>
         switch (cb) {
         | Some(_cb) => id
         | None => ""
         }
       )
    |> List.filter(id => id != "")
    |> Array.of_list;

  if (sortContentBlock == true) {
    SortContentBlockMutation.make(~contentBlockIds, ())
    |> GraphqlQuery.sendQuery(authenticityToken, ~notify=false)
    |> Js.Promise.then_(_response => Js.Promise.resolve())
    |> ignore;
    toggleSortContentBlock(_ => false);
  } else {
    ();
  };
  None;
};

let updateContentBlockMasterList =
    (sortedContentBlocks, updateContentBlocksCB, targetId) => {
  let updatedCBs =
    sortedContentBlocks
    |> List.filter(((_, _, cb, _)) =>
         switch (cb) {
         | Some(_) => true
         | None => false
         }
       )
    |> List.map(((sortIndex, blockType, _, id)) =>
         ContentBlock.make(id, blockType, targetId, sortIndex)
       );
  updateContentBlocksCB(targetId, updatedCBs);
};

[@react.component]
let make =
    (~target, ~contentBlocks, ~updateContentBlocksCB, ~authenticityToken) => {
  let (targetContentBlocks, updateTargetContentBlocks) =
    React.useState(() =>
      contentBlocks
      |> List.sort((x, y) =>
           ContentBlock.sortIndex(x) - ContentBlock.sortIndex(y)
         )
      |> List.mapi((index, cb) =>
           (
             index + 1,
             cb |> ContentBlock.blockType,
             Some(cb),
             cb |> ContentBlock.id,
           )
         )
    );
  let (sortContentBlock, toggleSortContentBlock) =
    React.useState(() => false);

  let sortedContentBlocks =
    targetContentBlocks
    |> List.sort((x, y) => {
         let (x, _, _, _) = x;
         let (y, _, _, _) = y;
         x - y;
       });

  let removeTargetContentCB = (contentBlockId, sortIndex) => {
    let updatedContentBlockList =
      targetContentBlocks
      |> List.filter(((index, _, _, _)) => sortIndex != index);
    switch (contentBlockId) {
    | Some(_contentBlockId) =>
      updateTargetContentBlocks(_ => updatedContentBlockList);
      updateContentBlockMasterList(
        updatedContentBlockList,
        updateContentBlocksCB,
        target |> Target.id,
      );
    | None => updateTargetContentBlocks(_ => updatedContentBlockList)
    };
    toggleSortContentBlock(sortContentBlock => !sortContentBlock);
  };

  React.useEffect1(
    updateContentBlockSorting(
      sortedContentBlocks,
      authenticityToken,
      sortContentBlock,
      toggleSortContentBlock,
    ),
    [|sortContentBlock|],
  );

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

  let createNewContentCB = contentBlock => {
    let newContentBlock = (
      ContentBlock.sortIndex(contentBlock),
      ContentBlock.blockType(contentBlock),
      Some(contentBlock),
      ContentBlock.id(contentBlock),
    );
    let updatedContentBlockList =
      targetContentBlocks
      |> List.filter(((index, _, _, _)) =>
           index != ContentBlock.sortIndex(contentBlock)
         )
      |> List.append([newContentBlock]);
    updateTargetContentBlocks(_ => updatedContentBlockList);
    toggleSortContentBlock(sortContentBlock => !sortContentBlock);
    updateContentBlockMasterList(
      updatedContentBlockList,
      updateContentBlocksCB,
      target |> Target.id,
    );
  };

  let updateContentBlockCB = contentBlock => {
    let newContentBlock = (
      ContentBlock.sortIndex(contentBlock),
      ContentBlock.blockType(contentBlock),
      Some(contentBlock),
      ContentBlock.id(contentBlock),
    );
    let updatedContentBlockList =
      targetContentBlocks
      |> List.filter(((_, _, _, id)) =>
           id != ContentBlock.id(contentBlock)
         )
      |> List.append([newContentBlock]);
    updateTargetContentBlocks(_ => updatedContentBlockList);
    updateContentBlockMasterList(
      updatedContentBlockList,
      updateContentBlocksCB,
      target |> Target.id,
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
    let updatedContentBlockList =
      List.append(updatedlowerCBs, updatedUpperCBs);
    updateTargetContentBlocks(_ => updatedContentBlockList);
    updateContentBlockMasterList(
      updatedContentBlockList,
      updateContentBlocksCB,
      target |> Target.id,
    );
    toggleSortContentBlock(sortContentBlock => !sortContentBlock);
  };

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
    let updatedContentBlockList =
      List.append(updatedlowerCBs, updatedUpperCBs);
    updateTargetContentBlocks(_ => updatedContentBlockList);
    updateContentBlockMasterList(
      updatedContentBlockList,
      updateContentBlocksCB,
      target |> Target.id,
    );
    toggleSortContentBlock(sortContentBlock => !sortContentBlock);
  };

  [|
    <CurriculumEditor__ContentTypePicker
      key="static-content-picker"
      sortIndex={
                  let (sortIndex, _, _, _) =
                    sortedContentBlocks |> List.rev |> List.hd;
                  sortIndex + 1;
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
              editorId=id
              target
              contentBlock
              removeTargetContentCB
              blockType
              sortIndex
              newContentBlockCB
              createNewContentCB
              updateContentBlockCB
              moveContentUpCB
              moveContentDownCB
              authenticityToken
            />
          )
       |> Array.of_list,
     )
  |> React.array;
};