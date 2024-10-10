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
  let progressionLimit = {
    open Json.Decode
    field("progressionLimit", int)
  }(json)
  let progressionBehavior = switch progressionLimit {
  | 0 => Unlimited
  | limit => Limited(limit)
  }

  open Json.Decode
  {
    id: field("id", string, json),
    ended: field("ended", bool, json),
    certificateSerialNumber: option(field("certificateSerialNumber", string), json),
    progressionBehavior,
  }
}
