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

let decodeMarkdownContent = json => {
  open Json.Decode
  field("markdown", string, json)
}
let decodeFileContent = json => {
  open Json.Decode
  field("title", string, json)
}

let decodeImageContent = json => {
  let widthString = {
    open Json.Decode
    field("width", string, json)
  }

  let width = switch widthString {
  | "Auto" => Auto
  | "Full" => Full
  | "FourFifths" => FourFifths
  | "ThreeFifths" => ThreeFifths
  | "TwoFifths" => TwoFifths
  | otherWidth =>
    Rollbar.error("Encountered unexpected width for image content block: " ++ otherWidth)
    Auto
  }

  (
    {
      open Json.Decode
      field("caption", string, json)
    },
    width,
  )
}

let decodeEmbedContent = json => {
  let requestSourceString = {
    open Json.Decode
    field("requestSource", string, json)
  }

  let requestSource = switch requestSourceString {
  | "User" => #User
  | "VimeoUpload" => #VimeoUpload
  | otherRequestSource =>
    Rollbar.error("Unexpected requestSource encountered in ContentBlock.re: " ++ otherRequestSource)
    raise(UnexpectedRequestSource(otherRequestSource))
  }

  open Json.Decode
  (
    field("url", string, json),
    option(field("embedCode", string), json),
    requestSource,
    option(field("lastResolvedAt", DateFns.decodeISO), json),
  )
}

let decode = json => {
  open Json.Decode

  let blockType = switch field("blockType", string, json) {
  | "markdown" =>
    let markdown = field("content", decodeMarkdownContent, json)
    Markdown(markdown)
  | "file" =>
    let title = field("content", decodeFileContent, json)
    let url = field("fileUrl", string, json)
    let filename = field("filename", string, json)
    File(url, title, filename)
  | "image" =>
    let (caption, width) = field("content", decodeImageContent, json)
    let url = field("fileUrl", string, json)
    Image(url, caption, width)
  | "embed" =>
    let (url, embedCode, requestSource, lastResolvedAt) = field("content", decodeEmbedContent, json)
    Embed(url, embedCode, requestSource, lastResolvedAt)
  | "audio" =>
    let title = field("content", decodeFileContent, json)
    let url = field("fileUrl", string, json)
    let filename = field("filename", string, json)
    Audio(url, title, filename)
  | unknownBlockType => raise(UnexpectedBlockType(unknownBlockType))
  }

  {
    id: field("id", string, json),
    blockType,
    sortIndex: field("sortIndex", int, json),
  }
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
