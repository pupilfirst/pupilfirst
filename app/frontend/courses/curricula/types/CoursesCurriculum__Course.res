exception UnexpectedProgressionBehavior(string)

type progressionBehavior =
  | Limited(int)
  | Unlimited

type t = {
  id: string,
  ended: bool,
  certificateSerialNumber: option<string>,
  progressionBehavior: progressionBehavior,
}

let ended = t => t.ended

let id = t => t.id

let certificateSerialNumber = t => t.certificateSerialNumber

let progressionBehavior = t => t.progressionBehavior

let progressionLimit = t => {
  switch t.progressionBehavior {
  | Limited(limit) => limit
  | Unlimited => 0
  }
}

let decode = json => {
  let progressionLimit = json |> {
    open Json.Decode
    field("progressionLimit", int)
  }
  let progressionBehavior = switch progressionLimit {
  | 0 => Unlimited
  | limit => Limited(limit)
  }

  open Json.Decode
  {
    id: json |> field("id", string),
    ended: json |> field("ended", bool),
    certificateSerialNumber: json |> optional(field("certificateSerialNumber", string)),
    progressionBehavior: progressionBehavior,
  }
}
