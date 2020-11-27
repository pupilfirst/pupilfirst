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
  json |> field("markdown", string)
}
let decodeFileContent = json => {
  open Json.Decode
  json |> field("title", string)
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
      json |> field("caption", string)
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
    json |> field("url", string),
    json |> optional(field("embedCode", string)),
    requestSource,
    json |> optional(field("lastResolvedAt", DateFns.decodeISO)),
  )
}

let decode = json => {
  open Json.Decode

  let blockType = switch json |> field("blockType", string) {
  | "markdown" => Markdown(json |> field("content", decodeMarkdownContent))
  | "file" =>
    let title = json |> field("content", decodeFileContent)
    let url = json |> field("fileUrl", string)
    let filename = json |> field("filename", string)
    File(url, title, filename)
  | "image" =>
    let (caption, width) = json |> field("content", decodeImageContent)
    let url = json |> field("fileUrl", string)
    Image(url, caption, width)
  | "embed" =>
    let (url, embedCode, requestSource, lastResolvedAt) =
      json |> field("content", decodeEmbedContent)
    Embed(url, embedCode, requestSource, lastResolvedAt)
  | unknownBlockType => raise(UnexpectedBlockType(unknownBlockType))
  }

  {
    id: json |> field("id", string),
    blockType: blockType,
    sortIndex: json |> field("sortIndex", int),
  }
}

let sort = blocks => blocks |> ArrayUtils.copyAndSort((x, y) => x.sortIndex - y.sortIndex)

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

let make = (id, blockType, sortIndex) => {id: id, blockType: blockType, sortIndex: sortIndex}

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
  }

  make(id, blockType, sortIndex)
}

let blockTypeAsString = blockType =>
  switch blockType {
  | Markdown(_) => "markdown"
  | File(_) => "file"
  | Image(_) => "image"
  | Embed(_) => "embed"
  }

let incrementSortIndex = t => {...t, sortIndex: t.sortIndex + 1}

let reindex = ts => ts |> List.mapi((sortIndex, t) => {...t, sortIndex: sortIndex})

let moveUp = (t, ts) =>
  ts |> sort |> Array.to_list |> ListUtils.swapUp(t) |> reindex |> Array.of_list

let moveDown = (t, ts) =>
  ts |> sort |> Array.to_list |> ListUtils.swapDown(t) |> reindex |> Array.of_list

let updateFile = (title, t) =>
  switch t.blockType {
  | File(url, _, filename) => {...t, blockType: File(url, title, filename)}
  | Markdown(_)
  | Image(_)
  | Embed(_) => t
  }

let updateImageCaption = (t, caption) =>
  switch t.blockType {
  | Image(url, _, width) => {...t, blockType: Image(url, caption, width)}
  | Markdown(_)
  | File(_)
  | Embed(_) => t
  }

let updateImageWidth = (t, width) =>
  switch t.blockType {
  | Image(url, caption, _) => {...t, blockType: Image(url, caption, width)}
  | Markdown(_)
  | File(_)
  | Embed(_) => t
  }

let updateMarkdown = (markdown, t) =>
  switch t.blockType {
  | Markdown(_) => {...t, blockType: Markdown(markdown)}
  | File(_)
  | Image(_)
  | Embed(_) => t
  }

module Fragments = %graphql(
  `
  fragment allFields on ContentBlock {
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
`
)

module Query = %graphql(
  `
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
`
)
