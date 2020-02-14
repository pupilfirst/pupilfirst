type kind =
  | Files
  | Link
  | ShortText
  | LongText
  | MultiChoice;

type t = {
  title: string,
  kind: option(kind),
  optional: bool,
};

let decodeKindString = string => {
  switch (string) {
  | "files" => Files
  | "link" => Link
  | "short_text" => ShortText
  | "long_text" => LongText
  | "multi_choice" => MultiChoice
  | kind =>
    Rollbar.error(
      "Unkown kind: "
      ++ kind
      ++ "recived in CurriculumEditor__TargetChecklistItem",
    );
    LongText;
  };
};

let kindFromJs = data => {
  data |> OptionUtils.map(decodeKindString);
};

let makeFromJs = data => {
  title: data##title,
  kind: kindFromJs(data##kind),
  optional: data##optional,
};
