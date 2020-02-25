type choices = array(string);

type kind =
  | Files
  | Link
  | ShortText
  | LongText
  | MultiChoice(choices);

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
  | Link => "Attach a Link"
  | ShortText => "Write Short Text"
  | LongText => "Write Long Text"
  | MultiChoice(_choices) => "Choose from a list"
  };
};

let kindAsString = kind => {
  switch (kind) {
  | Files => "files"
  | Link => "link"
  | ShortText => "shortText"
  | LongText => "longText"
  | MultiChoice(_choices) => "multiChoice"
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

let removeItem = (index, list) => {
  list |> Js.Array.filteri((_item, i) => i != index);
};

let swap = (f, list) => {
  list
  |> Js.Array.mapi((l, i) => (i, l))
  |> Array.to_list
  |> f
  |> Array.of_list
  |> Array.map(((_i, a)) => a);
};
let moveUp = (t, index, list) => {
  list |> swap(ListUtils.swapUp((index, t)));
};

let moveDown = (t, index, list) => {
  list |> swap(ListUtils.swapDown((index, t)));
};

let copy = (t, list) => {
  list
  |> Array.map(item => item == t ? [item, item] : [item])
  |> ArrayUtils.flatten;
};

let removeMultichoiceOption = (choiceIndex, t) => {
  switch (t.kind) {
  | MultiChoice(choices) =>
    let updatedChoices =
      choices
      |> Array.mapi((i, choice) => i == choiceIndex ? [] : [choice])
      |> ArrayUtils.flatten;
    t |> updateKind(MultiChoice(updatedChoices));
  | Files
  | Link
  | ShortText
  | LongText => t
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
  | LongText => t
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
  | LongText => t
  };
};

let createNew = {title: "", kind: LongText, optional: false};

let metaData = kind => {
  switch (kind) {
  | MultiChoice(choices) => choices
  | Files
  | Link
  | ShortText
  | LongText => [||]
  };
};

let isFilesKind = t => {
  switch (t.kind) {
  | Files => true
  | MultiChoice(_choices) => false
  | Link
  | ShortText
  | LongText => false
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
  | LongText => t.title |> String.trim |> String.length >= 1
  };
};

let createDefaultChecklist = [|
  make(~title="Describe your submission", ~kind=LongText, ~optional=false),
|];

let kindFromJs = (data, metaData) => {
  switch (data) {
  | "files" => Files
  | "link" => Link
  | "shortText" => ShortText
  | "longText" => LongText
  | "multiChoice" => MultiChoice(OptionUtils.default([||], metaData))
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
        json |> Json.Decode.optional(field("metaData", array(string))),
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
