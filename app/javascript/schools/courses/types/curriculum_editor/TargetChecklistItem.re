type choices = array(string);

type kind =
  | Files
  | Link
  | ShortText
  | LongText
  | MultiChoice(choices)
  | Statement;

type t = {
  title: string,
  kind,
  optional: bool,
};

let title = t => t.title;
let kind = t => t.kind;
let optional = t => t.optional;

let actionStringForKind = kind => {
  switch (kind) {
  | Files => "Upload Files"
  | Link => "Attach Links"
  | ShortText => "Write Short Text"
  | LongText => "Write Long Text"
  | MultiChoice(_choices) => "Choose from a list"
  | Statement => "Read Statement"
  };
};

let kindAsString = kind => {
  switch (kind) {
  | Files => "files"
  | Link => "link"
  | ShortText => "shortText"
  | LongText => "longText"
  | MultiChoice(_choices) => "multiChoice"
  | Statement => "statement"
  };
};

let make = (~title, ~kind, ~optional) => {
  {title, kind, optional};
};

let updateTitle = (title, t) => {
  {...t, title};
};

let updateKind = (kind, t) => {
  {...t, kind};
};

let updateOptional = (optional, t) => {
  {...t, optional};
};

let removeMultichoiceOption = (choiceIndex, t) => {
  switch (t.kind) {
  | MultiChoice(choices) =>
    let updatedChoices =
      choices
      |> Array.mapi((i, choice) => i == choiceIndex ? [] : [choice])
      |> Array.to_list
      |> List.flatten
      |> Array.of_list;
    t |> updateKind(MultiChoice(updatedChoices));
  | Files
  | Link
  | ShortText
  | LongText
  | Statement => t
  };
};

let addMultichoiceOption = t => {
  switch (t.kind) {
  | MultiChoice(choices) =>
    let updatedChoices = [|""|] |> Array.append(choices);
    t |> updateKind(MultiChoice(updatedChoices));
  | Files
  | Link
  | ShortText
  | LongText
  | Statement => t
  };
};

let updateMultichoiceOption = (choiceIndex, newOption, t) => {
  switch (t.kind) {
  | MultiChoice(choices) =>
    let updatedChoices =
      choices
      |> Array.mapi((i, choice) => i == choiceIndex ? newOption : choice);
    t |> updateKind(MultiChoice(updatedChoices));
  | Files
  | Link
  | ShortText
  | LongText
  | Statement => t
  };
};

let createNew = {title: "", kind: LongText, optional: false};

let metaData = kind => {
  switch (kind) {
  | MultiChoice(choices) => choices
  | Files
  | Link
  | ShortText
  | LongText
  | Statement => [||]
  };
};

let isValidChecklistItem = t => {
  switch (t.kind) {
  | MultiChoice(choices) =>
    choices
    |> Js.Array.filter(choice => choice |> String.trim |> String.length < 1)
    |> ArrayUtils.isEmpty
    && t.title
    |> String.trim
    |> String.length >= 1
  | Files
  | Link
  | ShortText
  | LongText
  | Statement => t.title |> String.trim |> String.length >= 1
  };
};

let kindFromJs = (data, metaData) => {
  switch (data) {
  | "files" => Files
  | "link" => Link
  | "shortText" => ShortText
  | "longText" => LongText
  | "multiChoice" => MultiChoice(OptionUtils.default([||], metaData))
  | "statement" => Statement
  | kind =>
    Rollbar.error(
      "Unkown kind: "
      ++ kind
      ++ "recived in CurriculumEditor__TargetChecklistItem",
    );
    LongText;
  };
};

let decode = json => {
  Json.Decode.{
    kind:
      kindFromJs(
        json |> field("kind", string),
        json |> optional(field("metaData", array(string))),
      ),
    optional: json |> field("optional", bool),
    title: json |> field("title", string),
  };
};

let encode = t =>
  Json.Encode.(
    object_([
      ("kind", t.kind |> kindAsString |> string),
      ("title", t.title |> string),
      ("optional", t.optional |> bool),
      ("metaData", t.kind |> metaData |> stringArray),
    ])
  );

let encodeChecklist = checklist => checklist |> Json.Encode.(array(encode));
