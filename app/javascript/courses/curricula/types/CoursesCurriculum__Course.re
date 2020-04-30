exception UnexpectedProgressionBehavior(string);

type progressionBehavior =
  | Limited(int)
  | Unlimited
  | Strict;

type t = {
  id: string,
  endsAt: option(string),
  certificateSerialNumber: option(string),
  progressionBehavior,
};

let decode = json => {
  let behavior = json |> Json.Decode.(field("progressionBehavior", string));
  let progressionBehavior =
    switch (behavior) {
    | "Limited" =>
      let progressionLimit =
        json |> Json.Decode.(field("progressionLimit", int));
      Limited(progressionLimit);
    | "Unlimited" => Unlimited
    | "Strict" => Strict
    | otherValue =>
      Rollbar.error("Unexpected progressionBehavior: " ++ otherValue);
      raise(UnexpectedProgressionBehavior(behavior));
    };

  Json.Decode.{
    id: json |> field("id", string),
    endsAt: json |> field("endsAt", nullable(string)) |> Js.Null.toOption,
    certificateSerialNumber:
      json |> optional(field("certificateSerialNumber", string)),
    progressionBehavior,
  };
};

let endsAt = t => t.endsAt;
let id = t => t.id;
let certificateSerialNumber = t => t.certificateSerialNumber;
let progressionBehavior = t =>
  switch (t.progressionBehavior) {
  | Strict => `Strict
  | Unlimited => `Unlimited
  | Limited(progressionLimit) => `Limited(progressionLimit)
  };

let hasEnded = t =>
  switch (t.endsAt) {
  | Some(date) => date |> DateFns.parseString |> DateFns.isPast
  | None => false
  };
