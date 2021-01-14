exception UnexpectedEligibilityString(string)

type t =
  | Eligible
  | AtMaxLevel
  | NoMilestonesInLevel
  | CurrentLevelIncomplete
  | PreviousLevelIncomplete
  | TeamMembersPending
  | DateLocked

let decode = json => {
  let stringValue = Json.Decode.string(json)

  switch stringValue {
  | "Eligible" => Eligible
  | "AtMaxLevel" => AtMaxLevel
  | "NoMilestonesInLevel" => NoMilestonesInLevel
  | "CurrentLevelIncomplete" => CurrentLevelIncomplete
  | "PreviousLevelIncomplete" => PreviousLevelIncomplete
  | "TeamMembersPending" => TeamMembersPending
  | "DateLocked" => DateLocked
  | otherValue =>
    Rollbar.error("Unexpected eligibility encountered: " ++ otherValue)
    raise(UnexpectedEligibilityString(otherValue))
  }
}

let isEligible = t =>
  switch t {
  | Eligible => true
  | AtMaxLevel
  | NoMilestonesInLevel
  | CurrentLevelIncomplete
  | PreviousLevelIncomplete
  | TeamMembersPending
  | DateLocked => false
  }

let makeOptionFromJs = js => Belt.Option.map(js, eligibility =>
    switch eligibility {
    | #Eligible => Eligible
    | #AtMaxLevel => AtMaxLevel
    | #NoMilestonesInLevel => NoMilestonesInLevel
    | #CurrentLevelIncomplete => CurrentLevelIncomplete
    | #PreviousLevelIncomplete => PreviousLevelIncomplete
    | #TeamMembersPending => TeamMembersPending
    | #DateLocked => DateLocked
    }
  )
