let str = React.string

let t = I18n.t(~scope="components.CurriculumEditor__ContentEditor", ...)

open CurriculumEditor__Types

type state = {
  loading: bool,
  contentBlocks: array<ContentBlock.t>,
  versions: array<Version.t>,
  dirtyContentBlockIds: Belt.Set.String.t,
}

type action =
  | LoadContent(array<ContentBlock.t>, array<Version.t>)
  | AddContentBlock(ContentBlock.t)
  | UpdateContentBlock(ContentBlock.t)
  | RemoveContentBlock(ContentBlock.id)
  | MoveContentBlockUp(ContentBlock.t)
  | MoveContentBlockDown(ContentBlock.t)
  | SetDirty(ContentBlock.id, bool)

let reducer = (state, action) =>
  switch action {
  | LoadContent(contentBlocks, versions) => {
      loading: false,
      contentBlocks,
      versions,
      dirtyContentBlockIds: Belt.Set.String.empty,
    }
  | AddContentBlock(newContentBlock) =>
    let newBlockSortIndex = ContentBlock.sortIndex(newContentBlock)
    {
      ...state,
      contentBlocks: Array.append([newContentBlock], Array.map(contentBlock => {
          let sortIndex = ContentBlock.sortIndex(contentBlock)

          if sortIndex < newBlockSortIndex {
            contentBlock
          } else {
            ContentBlock.incrementSortIndex(contentBlock)
          }
        }, state.contentBlocks)),
    }
  | UpdateContentBlock(updatedContentBlock) => {
      ...state,
      contentBlocks: Array.map(
        contentBlock =>
          ContentBlock.id(contentBlock) == ContentBlock.id(updatedContentBlock)
            ? updatedContentBlock
            : contentBlock,
        state.contentBlocks,
      ),
      dirtyContentBlockIds: state.dirtyContentBlockIds->Belt.Set.String.remove(
        ContentBlock.id(updatedContentBlock),
      ),
    }
  | RemoveContentBlock(contentBlockId) => {
      ...state,
      contentBlocks: Js.Array.filter(
        contentBlock => ContentBlock.id(contentBlock) != contentBlockId,
        state.contentBlocks,
      ),
      dirtyContentBlockIds: state.dirtyContentBlockIds->Belt.Set.String.remove(contentBlockId),
    }
  | MoveContentBlockUp(contentBlock) => {
      ...state,
      contentBlocks: ContentBlock.moveUp(contentBlock, state.contentBlocks),
    }
  | MoveContentBlockDown(contentBlock) => {
      ...state,
      contentBlocks: ContentBlock.moveDown(contentBlock, state.contentBlocks),
    }
  | SetDirty(contentBlockId, dirty) =>
    let operation = dirty ? Belt.Set.String.add : Belt.Set.String.remove
    {
      ...state,
      dirtyContentBlockIds: operation(state.dirtyContentBlockIds, contentBlockId),
    }
  }

let loadContentBlocks = (targetId, send) => ignore(Js.Promise.then_(result => {
      let contentBlocks = Js.Array.map(ContentBlock.makeFromJs, result["contentBlocks"])

      let versions = Version.makeArrayFromJs(result["targetVersions"])

      send(LoadContent(contentBlocks, versions))

      Js.Promise.resolve()
    }, ContentBlock.Query.make({targetId, targetVersionId: None})))

let addContentBlock = (send, contentBlock) => send(AddContentBlock(contentBlock))

let removeContentBlock = (send, contentBlockId) => send(RemoveContentBlock(contentBlockId))

let moveContentBlockUp = (send, contentBlock) => send(MoveContentBlockUp(contentBlock))

let moveContentBlockDown = (send, contentBlock) => send(MoveContentBlockDown(contentBlock))

let setDirty = (contentBlockId, send, dirty) => send(SetDirty(contentBlockId, dirty))

let updateContentBlock = (send, contentBlock) => send(UpdateContentBlock(contentBlock))

let editor = (
  target,
  hasVimeoAccessToken,
  vimeoPlan,
  markdownCurriculumEditorMaxLength,
  state,
  send,
) => {
  let currentVersion = switch state.versions {
  | [] => <span className="italic"> {str(t("not_versioned"))} </span>
  | versions =>
    let latestVersion =
      versions->Array.unsafe_get(0)->Version.updatedAt->DateFns.format("MMM d, yyyy HH:mm")

    str(latestVersion)
  }

  let sortedContentBlocks = ContentBlock.sort(state.contentBlocks)
  let numberOfContentBlocks = Array.length(state.contentBlocks)

  let removeContentBlockCB = numberOfContentBlocks > 1 ? Some(removeContentBlock(send)) : None

  <div className="mt-2">
    <div className="flex justify-between items-end">
      {switch Target.visibility(target) {
      | Live =>
        <a
          href={"/targets/" ++ Target.id(target)}
          target="_blank"
          className="py-2 px-3 font-semibold rounded-lg text-sm bg-primary-100 text-primary-500 hhover:bg-primary-200 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500">
          <FaIcon classes="fas fa-external-link-alt rtl:-rotate-90" />
          <span className="ms-2"> {str(t("view_as_student"))} </span>
        </a>
      | Draft
      | Archived => React.null
      }}
      <div className="w-1/3 rtl:text-right rtl:text-left">
        <label className="text-xs block text-gray-600"> {str(t("last_updated"))} </label>
        <span className="text-sm font-semibold"> currentVersion </span>
      </div>
    </div>
    {React.array(Array.mapi((index, contentBlock) => {
        let moveContentBlockUpCB = index == 0 ? None : Some(moveContentBlockUp(send))
        let moveContentBlockDownCB =
          index + 1 == numberOfContentBlocks ? None : Some(moveContentBlockDown(send))
        let isDirty = state.dirtyContentBlockIds->Belt.Set.String.has(ContentBlock.id(contentBlock))
        let updateContentBlockCB = isDirty ? Some(updateContentBlock(send)) : None

        <div key={ContentBlock.id(contentBlock)}>
          <CurriculumEditor__ContentBlockCreator
            target
            hasVimeoAccessToken
            vimeoPlan
            aboveContentBlock=contentBlock
            addContentBlockCB={addContentBlock(send)}
          />
          <CurriculumEditor__ContentBlockEditor
            setDirtyCB={setDirty(ContentBlock.id(contentBlock), send)}
            contentBlock
            markdownCurriculumEditorMaxLength
            ?removeContentBlockCB
            ?moveContentBlockUpCB
            ?moveContentBlockDownCB
            ?updateContentBlockCB
          />
        </div>
      }, sortedContentBlocks))}
    <CurriculumEditor__ContentBlockCreator
      target hasVimeoAccessToken vimeoPlan addContentBlockCB={addContentBlock(send)}
    />
  </div>
}

@react.component
let make = (
  ~target,
  ~hasVimeoAccessToken,
  ~vimeoPlan,
  ~markdownCurriculumEditorMaxLength,
  ~setDirtyCB,
) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      loading: true,
      contentBlocks: [],
      versions: [],
      dirtyContentBlockIds: Belt.Set.String.empty,
    },
  )

  React.useEffect0(() => {
    loadContentBlocks(Target.id(target), send)
    None
  })

  React.useEffect1(() => {
    let dirty = !Belt.Set.String.isEmpty(state.dirtyContentBlockIds)
    setDirtyCB(dirty)
    None
  }, [state.dirtyContentBlockIds])

  <div className="max-w-3xl py-6 px-3 mx-auto">
    {state.loading
      ? SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.contents())
      : editor(
          target,
          hasVimeoAccessToken,
          vimeoPlan,
          markdownCurriculumEditorMaxLength,
          state,
          send,
        )}
  </div>
}
