[@bs.config {jsx: 3}];

module SortContentBlockMutation = [%graphql
  {|
   mutation($contentBlockIds: [ID!]!) {
    sortContentBlocks(contentBlockIds: $contentBlockIds) {
       success
       versions
     }
   }
   |}
];

let updateContentBlockSorting =
    (
      contentBlocks,
      authenticityToken,
      addNewVersionCB,
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
    |> Js.Promise.then_(response => {
         let versions =
           response##sortContentBlocks##versions
           |> Array.map(version => version |> Json.Decode.string);
         addNewVersionCB(versions);
         Js.Promise.resolve();
       })
    |> ignore;
    toggleSortContentBlock(_ => false);
  } else {
    ();
  };
  None;
};

let removeTargetContentCB =
    (
      contentBlock,
      sortedContentBlocks,
      addNewVersionCB,
      updateTargetContentBlocks,
      toggleSortContentBlock,
      sortIndex,
      versions,
    ) => {
  let updatedContentBlockList =
    sortedContentBlocks
    |> List.filter(((index, _, _, _)) => sortIndex != index)
    |> List.mapi((index, (_, blockType, contentBlock, id)) =>
         (index + 1, blockType, contentBlock, id)
       );
  updateTargetContentBlocks(_ => updatedContentBlockList);

  toggleSortContentBlock(sortContentBlock => !sortContentBlock);
  switch (contentBlock) {
  | Some(_cb) => addNewVersionCB(versions)
  | None => ()
  };
};

let swapContentBlockCB =
    (
      targetContentBlocks,
      updateTargetContentBlocks,
      toggleSortContentBlock,
      upperSortIndex,
      lowerSortIndex,
    ) => {
  let upperContentBlock =
    targetContentBlocks
    |> ListUtils.unsafeFind(
         ((index, _, _, _)) => index == upperSortIndex,
         "Unable to find content block with this sort index",
       );
  let lowerContentBlock =
    targetContentBlocks
    |> ListUtils.unsafeFind(
         ((index, _, _, _)) => index == lowerSortIndex,
         "Unable to find content block with this sort index",
       );
  let (sortIndex1, blockType1, cb1, id1) = lowerContentBlock;
  let (sortIndex2, blockType2, cb2, id2) = upperContentBlock;

  updateTargetContentBlocks(targetContentBlocks =>
    targetContentBlocks
    |> List.filter(((index, _, _, _)) =>
         !([lowerSortIndex, upperSortIndex] |> List.mem(index))
       )
    |> List.append([
         (sortIndex1, blockType2, cb2, id2),
         (sortIndex2, blockType1, cb1, id1),
       ])
  );
  toggleSortContentBlock(sortContentBlock => !sortContentBlock);
};

let createNewContentCB =
    (addNewVersionCB, updateTargetContentBlocks, contentBlock, versions) => {
  let newContentBlock = (
    ContentBlock.sortIndex(contentBlock),
    ContentBlock.blockType(contentBlock),
    Some(contentBlock),
    ContentBlock.id(contentBlock),
  );
  updateTargetContentBlocks(targetContentBlocks =>
    targetContentBlocks
    |> List.filter(((index, _, _, _)) =>
         index != ContentBlock.sortIndex(contentBlock)
       )
    |> List.append([newContentBlock])
  );
  addNewVersionCB(versions);
};

let updateContentBlockCB =
    (
      addNewVersionCB,
      updateTargetContentBlocks,
      contentBlock,
      currentId,
      versions,
    ) => {
  let newContentBlock = (
    ContentBlock.sortIndex(contentBlock),
    ContentBlock.blockType(contentBlock),
    Some(contentBlock),
    ContentBlock.id(contentBlock),
  );
  updateTargetContentBlocks(targetContentBlocks =>
    targetContentBlocks
    |> List.filter(((_, _, _, id)) => id != currentId)
    |> List.append([newContentBlock])
  );
  addNewVersionCB(versions);
};

[@react.component]
let make =
    (
      ~target,
      ~previewMode,
      ~loadingContentBlocks,
      ~contentBlocks,
      ~addNewVersionCB,
      ~updateContentEditorDirtyCB,
      ~authenticityToken,
    ) => {
  let (targetContentBlocks, updateTargetContentBlocks) =
    React.useState(() => []);
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
      addNewVersionCB,
      sortContentBlock,
      toggleSortContentBlock,
    ),
    [|sortContentBlock|],
  );

  let contentEditorDirty =
    targetContentBlocks |> List.exists(((_, _, cb, _)) => cb == None);

  React.useEffect1(
    () => {
      updateContentEditorDirtyCB(contentEditorDirty);
      None;
    },
    [|contentEditorDirty|],
  );

  let initialRender = React.useRef(true);

  React.useEffect1(
    () => {
      if (initialRender |> React.Ref.current) {
        initialRender->React.Ref.setCurrent(false);
      } else {
        let cachedContentBlocks =
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
             );
        updateTargetContentBlocks(_ => cachedContentBlocks);
      };
      None;
    },
    [|contentBlocks|],
  );
  loadingContentBlocks
    ? {
      SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.contents());
    }
    : (
      switch (previewMode) {
      | false =>
        [|
          <CurriculumEditor__ContentBlockCreator
            key="static-content-picker"
            sortIndex={
              switch (sortedContentBlocks) {
              | [] => 1
              | nonEmptyList =>
                let (sortIndex, _, _, _) =
                  nonEmptyList |> List.rev |> List.hd;
                sortIndex + 1;
              }
            }
            staticMode=true
            createNewContentCB={createNewContentCB(
              addNewVersionCB,
              updateTargetContentBlocks,
            )}
          />,
        |]
        |> Array.append(
             sortedContentBlocks
             |> List.map(((sortIndex, blockType, contentBlock, id)) =>
                  <div key=id>
                    <CurriculumEditor__ContentBlockCreator
                      key={sortIndex |> string_of_int}
                      sortIndex
                      createNewContentCB={createNewContentCB(
                        addNewVersionCB,
                        updateTargetContentBlocks,
                      )}
                      staticMode=false
                    />
                    <CurriculumEditor__ContentBlockEditor
                      editorId=id
                      target
                      contentBlock
                      removeTargetContentCB={removeTargetContentCB(
                        contentBlock,
                        sortedContentBlocks,
                        addNewVersionCB,
                        updateTargetContentBlocks,
                        toggleSortContentBlock,
                      )}
                      blockType
                      sortIndex
                      updateContentBlockCB={updateContentBlockCB(
                        addNewVersionCB,
                        updateTargetContentBlocks,
                      )}
                      blockCount={targetContentBlocks |> List.length}
                      swapContentBlockCB={swapContentBlockCB(
                        sortedContentBlocks,
                        updateTargetContentBlocks,
                        toggleSortContentBlock,
                      )}
                      targetContentBlocks
                      authenticityToken
                    />
                  </div>
                )
             |> Array.of_list,
           )
        |> React.array
      | true =>
        let persistedBlocks =
          sortedContentBlocks
          |> List.map(((sortIndex, blockType, cb, _)) =>
               switch (cb) {
               | Some(cb) => [
                   ContentBlock.make(
                     cb |> ContentBlock.id,
                     blockType,
                     sortIndex,
                   ),
                 ]
               | None => []
               }
             )
          |> List.flatten;
        <TargetContentView contentBlocks=persistedBlocks />;
      }
    );
};
