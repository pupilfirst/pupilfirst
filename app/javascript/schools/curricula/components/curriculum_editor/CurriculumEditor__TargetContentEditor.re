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
    (
      sortedContentBlocks,
      updateContentBlocksCB,
      updateContentEditorDirtyCB,
      targetId,
    ) => {
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
  let contentEditorDirty =
    sortedContentBlocks |> List.exists(((_, _, cb, _)) => cb == None);
  updateContentEditorDirtyCB(contentEditorDirty);
  updateContentBlocksCB(targetId, updatedCBs);
};

let removeTargetContentCB =
    (
      targetContentBlocks,
      updateTargetContentBlocks,
      updateContentBlocksCB,
      updateContentEditorDirtyCB,
      target,
      toggleSortContentBlock,
      sortIndex,
    ) => {
  let updatedContentBlockList =
    targetContentBlocks
    |> List.filter(((index, _, _, _)) => sortIndex != index);
  updateTargetContentBlocks(_ => updatedContentBlockList);
  updateContentBlockMasterList(
    updatedContentBlockList,
    updateContentBlocksCB,
    updateContentEditorDirtyCB,
    target |> Target.id,
  );
  toggleSortContentBlock(sortContentBlock => !sortContentBlock);
};

let newContentBlockCB =
    (
      updateTargetContentBlocks,
      updateContentEditorDirtyCB,
      sortIndex,
      blockType: ContentBlock.blockType,
    ) => {
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
  updateContentEditorDirtyCB(true);
};

let swapContentBlockCB =
    (
      sortedContentBlocks,
      updateTargetContentBlocks,
      updateContentBlocksCB,
      updateContentEditorDirtyCB,
      target,
      toggleSortContentBlock,
      upperSortIndex,
      lowerSortIndex,
    ) => {
  let upperContentBlock =
    sortedContentBlocks
    |> ListUtils.unsafeFind(
         ((index, _, _, _)) => index == upperSortIndex,
         "Unable to find content block with this sort index",
       );
  let lowerContentBlock =
    sortedContentBlocks
    |> ListUtils.unsafeFind(
         ((index, _, _, _)) => index == lowerSortIndex,
         "Unable to find content block with this sort index",
       );
  let (sortIndex1, blockType1, cb1, id1) = lowerContentBlock;
  let (sortIndex2, blockType2, cb2, id2) = upperContentBlock;
  let updatedContentBlockList =
    sortedContentBlocks
    |> List.filter(((index, _, _, _)) =>
         !([lowerSortIndex, upperSortIndex] |> List.mem(index))
       )
    |> List.append([
         (sortIndex1, blockType2, cb2, id2),
         (sortIndex2, blockType1, cb1, id1),
       ]);
  updateTargetContentBlocks(_ => updatedContentBlockList);
  updateContentBlockMasterList(
    updatedContentBlockList,
    updateContentBlocksCB,
    updateContentEditorDirtyCB,
    target |> Target.id,
  );
  toggleSortContentBlock(sortContentBlock => !sortContentBlock);
};

let createNewContentCB =
    (
      targetContentBlocks,
      updateTargetContentBlocks,
      toggleSortContentBlock,
      updateContentBlocksCB,
      updateContentEditorDirtyCB,
      target,
      contentBlock,
    ) => {
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
    updateContentEditorDirtyCB,
    target |> Target.id,
  );
};

let updateContentBlockCB =
    (
      targetContentBlocks,
      updateTargetContentBlocks,
      updateContentBlocksCB,
      updateContentEditorDirtyCB,
      target,
      contentBlock,
    ) => {
  let newContentBlock = (
    ContentBlock.sortIndex(contentBlock),
    ContentBlock.blockType(contentBlock),
    Some(contentBlock),
    ContentBlock.id(contentBlock),
  );
  let updatedContentBlockList =
    targetContentBlocks
    |> List.filter(((_, _, _, id)) => id != ContentBlock.id(contentBlock))
    |> List.append([newContentBlock]);
  updateTargetContentBlocks(_ => updatedContentBlockList);
  updateContentBlockMasterList(
    updatedContentBlockList,
    updateContentBlocksCB,
    updateContentEditorDirtyCB,
    target |> Target.id,
  );
};

[@react.component]
let make =
    (
      ~target,
      ~contentBlocks,
      ~updateContentBlocksCB,
      ~updateContentEditorDirtyCB,
      ~authenticityToken,
    ) => {
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

  React.useEffect1(
    updateContentBlockSorting(
      sortedContentBlocks,
      authenticityToken,
      sortContentBlock,
      toggleSortContentBlock,
    ),
    [|sortContentBlock|],
  );

  [|
    <CurriculumEditor__ContentTypePicker
      key="static-content-picker"
      sortIndex={
        switch (sortedContentBlocks) {
        | [] => 1
        | nonEmptyList =>
          let (sortIndex, _, _, _) = nonEmptyList |> List.rev |> List.hd;
          sortIndex + 1;
        }
      }
      staticMode=true
      newContentBlockCB={
        newContentBlockCB(
          updateTargetContentBlocks,
          updateContentEditorDirtyCB,
        )
      }
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
              removeTargetContentCB={
                removeTargetContentCB(
                  targetContentBlocks,
                  updateTargetContentBlocks,
                  updateContentBlocksCB,
                  updateContentEditorDirtyCB,
                  target,
                  toggleSortContentBlock,
                )
              }
              blockType
              sortIndex
              newContentBlockCB={
                newContentBlockCB(
                  updateTargetContentBlocks,
                  updateContentEditorDirtyCB,
                )
              }
              createNewContentCB={
                createNewContentCB(
                  targetContentBlocks,
                  updateTargetContentBlocks,
                  toggleSortContentBlock,
                  updateContentBlocksCB,
                  updateContentEditorDirtyCB,
                  target,
                )
              }
              updateContentBlockCB={
                updateContentBlockCB(
                  targetContentBlocks,
                  updateTargetContentBlocks,
                  updateContentBlocksCB,
                  updateContentEditorDirtyCB,
                  target,
                )
              }
              blockCount={targetContentBlocks |> List.length}
              swapContentBlockCB={
                swapContentBlockCB(
                  sortedContentBlocks,
                  updateTargetContentBlocks,
                  updateContentBlocksCB,
                  updateContentEditorDirtyCB,
                  target,
                  toggleSortContentBlock,
                )
              }
              authenticityToken
            />
          )
       |> Array.of_list,
     )
  |> React.array;
};
