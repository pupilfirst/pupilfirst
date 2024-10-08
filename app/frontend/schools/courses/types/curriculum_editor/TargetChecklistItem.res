type choices = array<string>

type allowMultiple = bool

let t = I18n.t(~scope="components.TargetChecklistItem", ...)

type kind =
  | Files
  | Link
  | ShortText
  | LongText
  | MultiChoice(choices, allowMultiple)
  | AudioRecord

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
  | Files => t("action_string_upload_files")
  | Link => t("action_string_attach_link")
  | ShortText => t("action_string_write_short_text")
  | LongText => t("action_string_write_long_text")
  | MultiChoice(_choices, _allowMultiple) => t("action_string_choose_from_list")
  | AudioRecord => t("action_string_record_audio")
  }

let kindAsString = kind =>
  switch kind {
  | Files => "files"
  | Link => "link"
  | ShortText => "shortText"
  | AudioRecord => "audio"
  | LongText => "longText"
  | MultiChoice(_choices, _allowMultiple) => "multiChoice"
  }

let make = (~title, ~kind, ~optional) => {
  title,
  kind,
  optional,
}

let updateTitle = (title, t) => {
  ...t,
  title,
}

let updateKind = (kind, t) => {
  ...t,
  kind,
}

let updateOptional = (optional, t) => {
  ...t,
  optional,
}

let removeItem = (index, array) => Js.Array.filteri((_item, i) => i != index, array)

let moveUp = (index, array) => ArrayUtils.swapUp(index, array)

let moveDown = (index, array) => ArrayUtils.swapDown(index, array)

let copy = (index, array) =>
  Array.flat(Js.Array.mapi((item, i) => i == index ? [item, item] : [item], array))

let removeMultichoiceOption = (choiceIndex, t) =>
  switch t.kind {
  | MultiChoice(choices, _allowMultiple) =>
    let updatedChoices = Array.flat(
      Array.mapi((i, choice) => i == choiceIndex ? [] : [choice], choices),
    )

    updateKind(MultiChoice(updatedChoices, _allowMultiple), t)
  | Files
  | Link
  | AudioRecord
  | ShortText
  | LongText => t
  }

let addMultichoiceOption = t =>
  switch t.kind {
  | MultiChoice(choices, _allowMultiple) =>
    let updatedChoices = Js.Array.concat([""], choices)
    updateKind(MultiChoice(updatedChoices, _allowMultiple), t)
  | Files
  | Link
  | ShortText
  | AudioRecord
  | LongText => t
  }

let updateMultichoiceOption = (choiceIndex, newOption, t) =>
  switch t.kind {
  | MultiChoice(choices, _allowMultiple) =>
    let updatedChoices = Js.Array.mapi(
      (choice, i) => i == choiceIndex ? newOption : choice,
      choices,
    )

    updateKind(MultiChoice(updatedChoices, _allowMultiple), t)
  | Files
  | Link
  | ShortText
  | AudioRecord
  | LongText => t
  }

let updateAllowMultiple = (allowMultiple, t) =>
  switch t.kind {
  | MultiChoice(choices, _) => updateKind(MultiChoice(choices, allowMultiple), t)
  | Files
  | Link
  | ShortText
  | AudioRecord
  | LongText => t
  }

let longText = {title: "", kind: LongText, optional: false}

let isFilesKind = t =>
  switch t.kind {
  | Files => true
  | MultiChoice(_choices, _allowMultiple) => false
  | Link
  | ShortText
  | AudioRecord
  | LongText => false
  }

let isValidChecklistItem = t => {
  let titleValid = Js.String.length(Js.String.trim(t.title)) >= 1

  switch t.kind {
  | MultiChoice(choices, allowMultiple) =>
    (ArrayUtils.isEmpty(Js.Array.filter(choice => String.trim(choice) == "", choices)) &&
    titleValid &&
    allowMultiple === true) || allowMultiple === false
  | Files
  | Link
  | ShortText
  | AudioRecord
  | LongText => titleValid
  }
}

let decodeMetadata = (kind, json) => {
  open Json.Decode
  switch kind {
  | #MultiChoice =>
    MultiChoice(field("choices", array(string), json), field("allowMultiple", bool, json))
  }
}

let decode = json => {
  open Json.Decode
  {
    kind: switch field("kind", string, json) {
    | "files" => Files
    | "link" => Link
    | "shortText" => ShortText
    | "audio" => AudioRecord
    | "longText" => LongText
    | "multiChoice" => field("metadata", decodeMetadata(#MultiChoice), json)
    | otherKind =>
      Rollbar.error(
        "Unknown kind: " ++ (otherKind ++ " received in CurriculumEditor__TargetChecklistItem"),
      )
      LongText
    },
    optional: field("optional", bool, json),
    title: field("title", string, json),
  }
}

let encodeMetadata = kind =>
  switch kind {
  | MultiChoice(choices, allowMultiple) =>
    open Json.Encode
    object_(list{("choices", stringArray(choices)), ("allowMultiple", bool(allowMultiple))})
  | Files
  | Link
  | ShortText
  | AudioRecord
  | LongText =>
    open Json.Encode
    object_(list{})
  }

let encode = t => {
  open Json.Encode
  object_(list{
    ("kind", string(kindAsString(t.kind))),
    ("title", string(t.title)),
    ("optional", bool(t.optional)),
    ("metadata", encodeMetadata(t.kind)),
  })
}

let encodeChecklist = checklist =>
  {
    open Json.Encode
    array(encode)
  }(checklist)
