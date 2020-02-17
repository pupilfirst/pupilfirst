type kind =
  | Files
  | Link
  | ShortText
  | LongText
  | MultiChoice
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
  | MultiChoice => "Choose from the list"
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

let kindFromJs = data => {
  switch (data) {
  | "files" => Files
  | "link" => Link
  | "short_text" => ShortText
  | "long_text" => LongText
  | "multi_choice" => MultiChoice
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

let makeFromJs = data => {
  title: data##title,
  kind: kindFromJs(data##kind),
  optional: data##optional,
};

let decode = json => {
  Json.Decode.{
    kind: kindFromJs(json |> field("kind", string)),
    optional: json |> field("optional", bool),
    title: json |> field("title", string),
  };
};
