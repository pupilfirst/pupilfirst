exception InvalidBlockTypeForUpdate

let str = React.string

let t = I18n.t(~scope="components.CurriculumEditor__ContentBlockEditor")

type state = {
  dirty: bool,
  saving: option<string>,
  contentBlock: ContentBlock.t,
}

let computeInitialState = contentBlock => {
  saving: None,
  contentBlock: contentBlock,
  dirty: false,
}

type action =
  | StartSaving(string)
  | FinishSaving
  | UpdateContentBlock(ContentBlock.t, bool)
  | FailSaving

let reducer = (state, action) =>
  switch action {
  | StartSaving(message) => {...state, saving: Some(message)}
  | FinishSaving => {...state, saving: None, dirty: false}
  | UpdateContentBlock(contentBlock, dirty) => {
      ...state,
      contentBlock: contentBlock,
      dirty: dirty,
    }
  | FailSaving => {...state, saving: None}
  }

module DeleteContentBlockMutation = %graphql(`
    mutation DeleteContentBlockMutation($id: ID!) {
      deleteContentBlock(id: $id) {
        success
      }
    }
  `)

module ContentBlockFragment = ContentBlock.Fragment

module MoveContentBlockMutation = %graphql(`
    mutation MoveContentBlockMutation($id: ID!, $direction: MoveDirection!) {
      moveContentBlock(id: $id, direction: $direction) {
        success
      }
    }
  `)

module UpdateFileBlockMutation = %graphql(`
    mutation UpdateFileBlockMutation($id: ID!, $title: String!) {
      updateFileBlock(id: $id, title: $title) {
        contentBlock {
          ...ContentBlockFragment
        }
      }
    }
  `)

module UpdateMarkdownBlockMutation = %graphql(`
    mutation UpdateMarkdownBlockMutation($id: ID!, $markdown: String!) {
      updateMarkdownBlock(id: $id, markdown: $markdown) {
        contentBlock {
          ...ContentBlockFragment
        }
      }
    }
  `)

module UpdateImageBlockMutation = %graphql(`
    mutation UpdateImageBlockMutation($id: ID!, $caption: String!, $width:ImageWidth! ) {
      updateImageBlock(id: $id, caption: $caption, width:$width) {
        contentBlock {
          ...ContentBlockFragment
        }
      }
    }
  `)

let controlIcon = (~icon, ~title, ~color, ~handler) => {
  let buttonClasses = switch color {
  | #Grey => "hover:bg-gray-50 hover:text-primary-500 focus:bg-gray-50 focus:text-primary-500"
  | #Green => "bg-green-600 hover:bg-green-700 focus:bg-green-700 text-white rounded-b"
  | #Red => "hover:text-red-500 focus:text-red-500"
  }

  handler == None
    ? React.null
    : <button
        title
        ariaLabel={title}
        disabled={handler == None}
        className={"p-2 focus:outline-none " ++ buttonClasses}
        onClick=?handler>
        <i className={"fas fa-fw " ++ icon} />
      </button>
}

let onMove = (contentBlock, cb, direction, _event) => {
  // We don't actually handle the response for this query.
  let variables = MoveContentBlockMutation.makeVariables(
    ~id=ContentBlock.id(contentBlock),
    ~direction,
    (),
  )
  MoveContentBlockMutation.make(variables) |> ignore

  cb(contentBlock)
}

let onDelete = (contentBlock, removeContentBlockCB, send, _event) =>
  WindowUtils.confirm(t("delete_block_confirm"), () => {
    send(StartSaving(t("deleting")))
    let id = ContentBlock.id(contentBlock)

    DeleteContentBlockMutation.make({id: id})
    |> Js.Promise.then_(result => {
      if result["deleteContentBlock"]["success"] {
        removeContentBlockCB(id)
      } else {
        send(FinishSaving)
      }

      Js.Promise.resolve()
    })
    |> Js.Promise.catch(_error => {
      send(FinishSaving)
      Js.Promise.resolve()
    })
    |> ignore
  })

let onUndo = (originalContentBlock, setDirtyCB, send, event) => {
  event |> ReactEvent.Mouse.preventDefault

  WindowUtils.confirm(t("undo_block_confirm"), () => {
    setDirtyCB(false)
    send(UpdateContentBlock(originalContentBlock, false))
  })
}

let handleUpdateResult = (updateContentBlockCB, setDirtyCB, send, contentBlock) => {
  switch contentBlock {
  | Some(contentBlock) =>
    contentBlock |> ContentBlock.makeFromJs |> updateContentBlockCB
    send(FinishSaving)
    setDirtyCB(false)
  | None => send(FailSaving)
  }
  Js.Promise.resolve()
}

let updateContentBlockBlock = (
  mutation,
  contentBlockExtractor,
  updateContentBlockCB,
  setDirtyCB,
  send,
) => {
  send(StartSaving(t("uploading")))

  mutation
  |> Js.Promise.then_(result =>
    result |> contentBlockExtractor |> handleUpdateResult(updateContentBlockCB, setDirtyCB, send)
  )
  |> Js.Promise.catch(_error => {
    send(FinishSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let onSave = (contentBlock, updateContentBlockCB, setDirtyCB, send, event) => {
  event |> ReactEvent.Mouse.preventDefault
  let id = ContentBlock.id(contentBlock)

  switch contentBlock |> ContentBlock.blockType {
  | ContentBlock.File(_url, title, _filename) =>
    let mutation = UpdateFileBlockMutation.make({id: id, title: title})

    let extractor = result => result["updateFileBlock"]["contentBlock"]

    updateContentBlockBlock(mutation, extractor, updateContentBlockCB, setDirtyCB, send)
  | Markdown(markdown) =>
    let mutation = UpdateMarkdownBlockMutation.make({id: id, markdown: markdown})
    let extractor = result => result["updateMarkdownBlock"]["contentBlock"]
    updateContentBlockBlock(mutation, extractor, updateContentBlockCB, setDirtyCB, send)
  | Image(_url, caption, imageWidth) =>
    let width = switch imageWidth {
    | ContentBlock.Auto => #Auto
    | Full => #Full
    | FourFifths => #FourFifths
    | ThreeFifths => #ThreeFifths
    | TwoFifths => #TwoFifths
    }

    let mutation = UpdateImageBlockMutation.make({id: id, caption: caption, width: width})
    let extractor = result => result["updateImageBlock"]["contentBlock"]

    updateContentBlockBlock(mutation, extractor, updateContentBlockCB, setDirtyCB, send)
  | Audio(_)
  | Embed(_) =>
    raise(InvalidBlockTypeForUpdate)
  }
}

let updateContentBlockCB = (originalContentBlock, setDirtyCB, state, send, newContentBlock) => {
  let dirty = newContentBlock != originalContentBlock

  if state.dirty != dirty {
    setDirtyCB(dirty)
  }

  send(UpdateContentBlock(newContentBlock, dirty))
}

let innerEditor = (
  originalContentBlock,
  contentBlock,
  setDirtyCB,
  state,
  send,
  markdownCurriculumEditorMaxLength,
) => {
  let updateContentBlockCB = updateContentBlockCB(originalContentBlock, setDirtyCB, state, send)

  switch contentBlock |> ContentBlock.blockType {
  | ContentBlock.Embed(url, embed, requestSource, lastResolvedAt) =>
    embed->Belt.Option.mapWithDefault(
      <CurriculumEditor__EmbedBlockResolver
        url requestSource contentBlockId={ContentBlock.id(contentBlock)} lastResolvedAt
      />,
      code => TargetContentView.embedContentBlock(code),
    )

  | Markdown(markdown) =>
    <CurriculumEditor__MarkdownBlockEditor
      markdown markdownCurriculumEditorMaxLength contentBlock updateContentBlockCB
    />
  | File(url, title, filename) =>
    <CurriculumEditor__FileBlockEditor url title filename contentBlock updateContentBlockCB />
  | Audio(url, _title, _filename) => <audio className="mx-auto" controls=true src=url />
  | Image(url, caption, width) =>
    <CurriculumEditor__ImageBlockEditor width url caption contentBlock updateContentBlockCB />
  }
}

@react.component
let make = (
  ~contentBlock,
  ~setDirtyCB,
  ~markdownCurriculumEditorMaxLength,
  ~removeContentBlockCB=?,
  ~moveContentBlockUpCB=?,
  ~moveContentBlockDownCB=?,
  ~updateContentBlockCB=?,
) => {
  let (state, send) = React.useReducerWithMapState(reducer, contentBlock, computeInitialState)

  <DisablingCover disabled={state.saving != None} message=?state.saving>
    <div className="bg-white border border-gray-200 rounded-xl">
      {switch ContentBlock.blockType(contentBlock) {
      | Embed(url, _, requestSource, _) =>
        let (icon, title) = switch requestSource {
        | #User => (<PfIcon className="if i-link-regular if-fw" />, t("embedded_url"))
        | #VimeoUpload => (<i className="fab fa-vimeo-v" />, t("video"))
        }
        <div className="flex py-2 gap-2 items-center px-2">
          <div
            className="bg-primary-100 text-primary-500 text-semibold rounded-full  items-center w-10 h-10 flex justify-center shrink-0">
            icon
          </div>
          <div className="w-full">
            <div className="text-sm"> {title->str} </div>
            <div className="flex items-center -mt-1">
              <a
                className="text-xs max-w-xs text-gray-500 truncate"
                href=url
                target="_blank"
                rel="noopener noreferrer">
                {url->str}
              </a>
              <ClickToCopy copy={url}> <PfIcon className="if i-copy-regular if-fw" /> </ClickToCopy>
            </div>
          </div>
        </div>
      | _ => React.null
      }}
      <div
        className="flex items-start"
        ariaLabel={t("editor_content_block") ++ (contentBlock |> ContentBlock.id)}>
        <div className="grow self-stretch min-w-0">
          {innerEditor(
            contentBlock,
            state.contentBlock,
            setDirtyCB,
            state,
            send,
            markdownCurriculumEditorMaxLength,
          )}
        </div>
        <div
          className="ps-2 shrink-0 border-transparent bg-gray-50 border rounded flex flex-col text-xs -me-10 sticky top-0">
          {controlIcon(
            ~icon="fa-arrow-up",
            ~title=t("move_up"),
            ~color=#Grey,
            ~handler=moveContentBlockUpCB |> OptionUtils.map(cb => onMove(contentBlock, cb, #Up)),
          )}
          {controlIcon(
            ~icon="fa-arrow-down",
            ~title=t("move_down"),
            ~color=#Grey,
            ~handler=moveContentBlockDownCB |> OptionUtils.map(cb =>
              onMove(contentBlock, cb, #Down)
            ),
          )}
          {controlIcon(
            ~icon="fa-trash-alt",
            ~title=t("delete"),
            ~color=#Red,
            ~handler=removeContentBlockCB |> OptionUtils.map(cb =>
              onDelete(contentBlock, cb, send)
            ),
          )}
          {controlIcon(
            ~icon="fa-undo-alt",
            ~title=t("undo_changes"),
            ~color=#Grey,
            ~handler=updateContentBlockCB |> OptionUtils.map(_cb =>
              onUndo(contentBlock, setDirtyCB, send)
            ),
          )}
          {controlIcon(
            ~icon="fa-check",
            ~title=t("save_changes"),
            ~color=#Green,
            ~handler=updateContentBlockCB |> OptionUtils.map(cb =>
              onSave(state.contentBlock, cb, setDirtyCB, send)
            ),
          )}
        </div>
      </div>
    </div>
  </DisablingCover>
}
