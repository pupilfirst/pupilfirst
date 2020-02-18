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

let kindFromJs = (data, metaData) => {
  Js.log(metaData);
  switch (data) {
  | "files" => Files
  | "link" => Link
  | "short_text" => ShortText
  | "long_text" => LongText
  | "multi_choice" => MultiChoice(OptionUtils.default([||], metaData))
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
        json |> optional(field("meta_data", array(string))),
      ),
    optional: json |> field("optional", bool),
    title: json |> field("title", string),
  };
};
