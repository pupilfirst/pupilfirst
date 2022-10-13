exception UnexpectedProgressionBehavior(string)

type progressionBehavior =
  | Limited(int)
  | Unlimited
  | Strict

type t = {
  id: string,
  ended: bool,
  certificateSerialNumber: option<string>,
  progressionBehavior: progressionBehavior,
}

let ended = t => t.ended

let id = t => t.id

let certificateSerialNumber = t => t.certificateSerialNumber

let progressionBehavior = t =>
  switch t.progressionBehavior {
  | Strict => #Strict
  | Unlimited => #Unlimited
  | Limited(progressionLimit) => #Limited(progressionLimit)
  }

let decode = json => {
  let behavior = json |> {
    open Json.Decode
    field("progressionBehavior", string)
  }

  let progressionBehavior = switch behavior {
  | "Limited" =>
    let progressionLimit = json |> {
      open Json.Decode
      field("progressionLimit", int)
    }
    Limited(progressionLimit)
  | "Unlimited" => Unlimited
  | "Strict" => Strict
  | otherValue =>
    Rollbar.error("Unexpected progressionBehavior: " ++ otherValue)
    raise(UnexpectedProgressionBehavior(behavior))
  }

  open Json.Decode
  {
    id: json |> field("id", string),
    ended: json |> field("ended", bool),
    certificateSerialNumber: json |> optional(field("certificateSerialNumber", string)),
    progressionBehavior: progressionBehavior,
  }
}
