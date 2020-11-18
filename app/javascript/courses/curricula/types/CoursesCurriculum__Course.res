exception UnexpectedProgressionBehavior(string)

type progressionBehavior =
  | Limited(int)
  | Unlimited
  | Strict

type t = {
  id: string,
  endsAt: option<Js.Date.t>,
  certificateSerialNumber: option<string>,
  progressionBehavior: progressionBehavior,
}

let endsAt = t => t.endsAt

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
    endsAt: (json |> optional(field("endsAt", string)))->Belt.Option.map(DateFns.parseISO),
    certificateSerialNumber: json |> optional(field("certificateSerialNumber", string)),
    progressionBehavior: progressionBehavior,
  }
}

let hasEnded = t => t.endsAt->Belt.Option.mapWithDefault(false, DateFns.isPast)
