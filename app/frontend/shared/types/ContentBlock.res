exception UnexpectedBlockType(string)
exception UnexpectedRequestSource(string)

type markdown = string
type url = string
type title = string
type caption = string
type embedCode = option<string>
type filename = string
type requestSource = [#User | #VimeoUpload]
type lastResolvedAt = option<Js.Date.t>

type width =
  | Auto
  | Full
  | FourFifths
  | ThreeFifths
  | TwoFifths

type blockType =
  | Markdown(markdown)
  | File(url, title, filename)
  | Image(url, caption, width)
  | Embed(url, embedCode, requestSource, lastResolvedAt)
  | Audio(url, title, filename)

type rec t = {
  id: id,
  blockType: blockType,
  sortIndex: int,
}
and id = string

let widthToClass = width =>
  switch width {
  | Auto => "w-auto"
  | Full => "w-full"
  | FourFifths => "w-4/5"
  | ThreeFifths => "w-3/5"
  | TwoFifths => "w-2/5"
  }

module Decode = {
  open Json.Decode

  let decodeWidth = string->map(s =>
    switch s {
    | "Auto" => Auto
    | "Full" => Full
    | "FourFifths" => FourFifths
    | "ThreeFifths" => ThreeFifths
    | "TwoFifths" => TwoFifths
    | otherWidth =>
      Rollbar.error("Encountered unexpected width for image content block: " ++ otherWidth)
      Auto
    }
  )

  let decodeRequestSource = string->map(s =>
    switch s {
    | "User" => #User
    | "VimeoUpload" => #VimeoUpload
    | otherRequestSource =>
      Rollbar.error(
        "Unexpected requestSource encountered in ContentBlock.re: " ++ otherRequestSource,
      )
      raise(UnexpectedRequestSource(otherRequestSource))
    }
  )

  let decodeMarkdown =
    field("content", field("markdown", string))->map(markdown => Markdown(markdown))

  let decodeFile = object(field => {
    let url = field.required("fileUrl", string)
    let title = field.required("content", field("title", string))
    let filename = field.required("filename", string)
    File(url, title, filename)
  })

  let decodeImage = object(field => {
    let url = field.required("fileUrl", string)
    let caption = field.required("content", field("caption", string))
    let width = field.required("content", field("width", decodeWidth))
    Image(url, caption, width)
  })

  let decodeEmbed = object(field => {
    let url = field.required("content", field("url", string))
    let embedCode = field.optional("content", field("embedCode", string))
    let requestSource = field.required("content", field("requestSource", decodeRequestSource))
    let lastResolvedAt = field.optional("content", field("lastResolvedAt", date))
    Embed(url, embedCode, requestSource, lastResolvedAt)
  })

  let decodeAudio = object(field => {
    let url = field.required("fileUrl", string)
    let title = field.required("content", field("title", string))
    let filename = field.required("filename", string)
    Audio(url, title, filename)
  })

  let decodeBlockType = field("blockType", string)->flatMap(blockType =>
    switch blockType {
    | "markdown" => decodeMarkdown
    | "file" => decodeFile
    | "image" => decodeImage
    | "embed" => decodeEmbed
    | "audio" => decodeAudio
    | unknownBlockType => raise(DecodeError(`Unexpected block type: ${unknownBlockType}`))
    }
  )

  let decode = object(field => {
    id: field.required("id", string),
    blockType: field.required("blockType", decodeBlockType),
    sortIndex: field.required("sortIndex", int),
  })
}

let sort = blocks => ArrayUtils.copyAndSort((x, y) => x.sortIndex - y.sortIndex, blocks)

let id = t => t.id
let blockType = t => t.blockType
let sortIndex = t => t.sortIndex

let makeMarkdownBlock = markdown => Markdown(markdown)
let makeImageBlock = (fileUrl, caption, width) => Image(fileUrl, caption, width)
let makeFileBlock = (fileUrl, title, fileName) => File(fileUrl, title, fileName)
let makeEmbedBlock = (url, embedCode, requestSource, lastResolvedAt) => Embed(
  url,
  embedCode,
  requestSource,
  lastResolvedAt,
)
let makeAudioBlock = (fileUrl, title, fileName) => Audio(fileUrl, title, fileName)
let make = (id, blockType, sortIndex) => {id, blockType, sortIndex}

let makeFromJs = js => {
  let id = js["id"]
  let sortIndex = js["sortIndex"]
  let blockType = switch js["content"] {
  | #MarkdownBlock(content) => Markdown(content["markdown"])
  | #FileBlock(content) => File(content["url"], content["title"], content["filename"])
  | #ImageBlock(content) =>
    Image(
      content["url"],
      content["caption"],
      switch content["width"] {
      | #Auto => Auto
      | #Full => Full
      | #FourFifths => FourFifths
      | #ThreeFifths => ThreeFifths
      | #TwoFifths => TwoFifths
      },
    )
  | #EmbedBlock(content) =>
    Embed(
      content["url"],
      content["embedCode"],
      content["requestSource"],
      content["lastResolvedAt"]->Belt.Option.map(DateFns.parseISO),
    )
  | #AudioBlock(content) => Audio(content["url"], content["title"], content["filename"])
  }

  make(id, blockType, sortIndex)
}

let blockTypeAsString = blockType =>
  switch blockType {
  | Markdown(_) => "markdown"
  | File(_) => "file"
  | Image(_) => "image"
  | Embed(_) => "embed"
  | Audio(_) => "audio"
  }

let incrementSortIndex = t => {...t, sortIndex: t.sortIndex + 1}

let reindex = ts => List.mapi((sortIndex, t) => {...t, sortIndex}, ts)

let moveUp = (t, ts) => Array.of_list(reindex(ListUtils.swapUp(t, Array.to_list(sort(ts)))))

let moveDown = (t, ts) => Array.of_list(reindex(ListUtils.swapDown(t, Array.to_list(sort(ts)))))

let updateFile = (title, t) =>
  switch t.blockType {
  | File(url, _, filename) => {...t, blockType: File(url, title, filename)}
  | Markdown(_)
  | Image(_)
  | Audio(_)
  | Embed(_) => t
  }

let updateImageCaption = (t, caption) =>
  switch t.blockType {
  | Image(url, _, width) => {...t, blockType: Image(url, caption, width)}
  | Markdown(_)
  | File(_)
  | Audio(_)
  | Embed(_) => t
  }

let updateImageWidth = (t, width) =>
  switch t.blockType {
  | Image(url, caption, _) => {...t, blockType: Image(url, caption, width)}
  | Markdown(_)
  | File(_)
  | Audio(_)
  | Embed(_) => t
  }

let updateMarkdown = (markdown, t) =>
  switch t.blockType {
  | Markdown(_) => {
      ...t,
      blockType: Markdown(markdown),
    }
  | File(_)
  | Image(_)
  | Audio(_)
  | Embed(_) => t
  }

module Query = %graphql(`
    query ContentBlocksWithVersionsQuery($targetId: ID!, $targetVersionId: ID) {
      contentBlocks(targetId: $targetId, targetVersionId: $targetVersionId) {
        id
        blockType
        sortIndex
        content {
          ... on ImageBlock {
            caption
            url
            filename
            width
          }
          ... on FileBlock {
            title
            url
            filename
          }
          ... on AudioBlock {
            title
            url
            filename
          }
          ... on MarkdownBlock {
            markdown
          }
          ... on EmbedBlock {
            url
            embedCode
            requestSource
            lastResolvedAt
          }
        }
      }
      targetVersions(targetId: $targetId){
        id
        createdAt
        updatedAt
      }
  }
`)

module Fragment = %graphql(`
  fragment ContentBlockFragment on ContentBlock {
    id
    blockType
    sortIndex
    content {
      ... on ImageBlock {
        caption
        url
        filename
        width
      }
      ... on FileBlock {
        title
        url
        filename
      }
      ... on AudioBlock {
        title
        url
        filename
      }
      ... on MarkdownBlock {
        markdown
      }
      ... on EmbedBlock {
        url
        embedCode
        requestSource
        lastResolvedAt
      }
    }
  }
`)
