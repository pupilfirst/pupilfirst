type choices = array<string>

type kind =
  | Files
  | Link
  | ShortText
  | LongText
  | MultiChoice(choices)

type t = {
  title: string,
  kind: kind,
  optional: bool,
}

let title = t => t.title
let kind = t => t.kind
let optional = t => t.optional

let actionStringForKind = kind =>
  switch kind {
  | Files => "Upload Files"
  | Link => "Attach a Link"
  | ShortText => "Write Short Text"
  | LongText => "Write Long Text"
  | MultiChoice(_choices) => "Choose from a list"
  }

let kindAsString = kind =>
  switch kind {
  | Files => "files"
  | Link => "link"
  | ShortText => "shortText"
  | LongText => "longText"
  | MultiChoice(_choices) => "multiChoice"
  }

let make = (~title, ~kind, ~optional) => {
  title: title,
  kind: kind,
  optional: optional,
}

let updateTitle = (title, t) => {
  ...t,
  title: title,
}

let updateKind = (kind, t) => {
  ...t,
  kind: kind,
}

let updateOptional = (optional, t) => {
  ...t,
  optional: optional,
}

let removeItem = (index, array) => array |> Js.Array.filteri((_item, i) => i != index)

let moveUp = (index, array) => array |> ArrayUtils.swapUp(index)

let moveDown = (index, array) => array |> ArrayUtils.swapDown(index)

let copy = (index, array) =>
  array |> Js.Array.mapi((item, i) => i == index ? [item, item] : [item]) |> ArrayUtils.flattenV2

let removeMultichoiceOption = (choiceIndex, t) =>
  switch t.kind {
  | MultiChoice(choices) =>
    let updatedChoices =
      choices |> Array.mapi((i, choice) => i == choiceIndex ? [] : [choice]) |> ArrayUtils.flattenV2

    updateKind(MultiChoice(updatedChoices), t)
  | Files
  | Link
  | ShortText
  | LongText => t
  }

let addMultichoiceOption = t =>
  switch t.kind {
  | MultiChoice(choices) =>
    let updatedChoices = Js.Array.concat([""], choices)
    updateKind(MultiChoice(updatedChoices), t)
  | Files
  | Link
  | ShortText
  | LongText => t
  }

let updateMultichoiceOption = (choiceIndex, newOption, t) =>
  switch t.kind {
  | MultiChoice(choices) =>
    let updatedChoices =
      choices |> Js.Array.mapi((choice, i) => i == choiceIndex ? newOption : choice)

    updateKind(MultiChoice(updatedChoices), t)
  | Files
  | Link
  | ShortText
  | LongText => t
  }

let longText = {title: "", kind: LongText, optional: false}

let isFilesKind = t =>
  switch t.kind {
  | Files => true
  | MultiChoice(_choices) => false
  | Link
  | ShortText
  | LongText => false
  }

let isValidChecklistItem = t => {
  let titleValid = Js.String.trim(t.title) |> Js.String.length >= 1

  switch t.kind {
  | MultiChoice(choices) =>
    choices |> Js.Array.filter(choice => String.trim(choice) == "") |> ArrayUtils.isEmpty &&
      titleValid
  | Files
  | Link
  | ShortText
  | LongText => titleValid
  }
}

let decodeMetadata = (kind, json) =>
  switch kind {
  | #MultiChoice =>
    json |> {
      open Json.Decode
      field("choices", array(string))
    }
  }

let decode = json => {
  open Json.Decode
  {
    kind: switch json |> field("kind", string) {
    | "files" => Files
    | "link" => Link
    | "shortText" => ShortText
    | "longText" => LongText
    | "multiChoice" => MultiChoice(json |> field("metadata", decodeMetadata(#MultiChoice)))
    | otherKind =>
      Rollbar.error(
        "Unkown kind: " ++ (otherKind ++ "received in CurriculumEditor__TargetChecklistItem"),
      )
      LongText
    },
    optional: json |> field("optional", bool),
    title: json |> field("title", string),
  }
}

let encodeMetadata = kind =>
  switch kind {
  | MultiChoice(choices) =>
    open Json.Encode
    object_(list{("choices", stringArray(choices))})
  | Files
  | Link
  | ShortText
  | LongText =>
    open Json.Encode
    object_(list{})
  }

let encode = t => {
  open Json.Encode
  object_(list{
    ("kind", t.kind |> kindAsString |> string),
    ("title", t.title |> string),
    ("optional", t.optional |> bool),
    ("metadata", t.kind |> encodeMetadata),
  })
}

let encodeChecklist = checklist =>
  checklist |> {
    open Json.Encode
    array(encode)
  }
