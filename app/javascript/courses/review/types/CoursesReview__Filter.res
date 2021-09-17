type selectedTab = [#Reviewed | #Pending]
type sortDirection = [#Ascending | #Descending]
type sortCriterion = [#EvaluatedAt | #SubmittedAt]

type t = {
  nameOrEmail: option<string>,
  levelId: option<string>,
  personalCoachId: option<string>,
  assignedCoachId: option<string>,
  targetId: option<string>,
  sortCriterion: sortCriterion,
  sortDirection: sortDirection,
  tab: option<selectedTab>,
  includeInactive: bool,
}

let nameOrEmail = t => t.nameOrEmail
let levelId = t => t.levelId
let targetId = t => t.targetId
let sortCriterion = t => t.sortCriterion
let sortDirection = t => t.sortDirection
let tab = t => t.tab
let includeInactive = t => t.includeInactive
let assignedCoachId = t => t.assignedCoachId
let personalCoachId = t => t.personalCoachId

let makeFromQueryParams = search => {
  let params = Webapi.Url.URLSearchParams.make(search)

  open Webapi.Url.URLSearchParams
  {
    nameOrEmail: get("search", params),
    levelId: get("levelId", params),
    personalCoachId: get("personalCoachId", params),
    assignedCoachId: get("assignedCoachId", params),
    targetId: get("targetId", params),
    tab: switch get("tab", params) {
    | Some(t) when t == "Pending" => Some(#Pending)
    | Some(t) when t == "Reviewed" => Some(#Reviewed)
    | _ => None
    },
    sortCriterion: switch get("sortCriterion", params) {
    | Some(criterion) when criterion == "EvaluatedAt" => #EvaluatedAt
    | Some(criterion) when criterion == "SubmittedAt" => #SubmittedAt
    | _ => #SubmittedAt
    },
    sortDirection: switch get("sortDirection", params) {
    | Some(direction) when direction == "Descending" => #Descending
    | Some(direction) when direction == "Ascending" => #Ascending
    | _ =>
      switch get("tab", params) {
      | Some(t) when t == "Pending" => #Ascending
      | _ => #Descending
      }
    },
    includeInactive: switch get("includeInactive", params) {
    | Some(t) when t == "true" => true
    | _ => false
    },
  }
}

let toQueryString = filter => {
  let sortCriterion = switch filter.sortCriterion {
  | #EvaluatedAt => "EvaluatedAt"
  | #SubmittedAt => "SubmittedAt"
  }

  let sortDirection = switch filter.sortDirection {
  | #Descending => "Descending"
  | #Ascending => "Ascending"
  }

  let filterDict = Js.Dict.fromArray([
    ("sortCriterion", sortCriterion),
    ("sortDirection", sortDirection),
  ])

  Belt.Option.forEach(filter.nameOrEmail, search => Js.Dict.set(filterDict, "search", search))
  Belt.Option.forEach(filter.targetId, targetId => Js.Dict.set(filterDict, "targetId", targetId))
  Belt.Option.forEach(filter.levelId, levelId => Js.Dict.set(filterDict, "levelId", levelId))
  Belt.Option.forEach(filter.personalCoachId, coachId =>
    Js.Dict.set(filterDict, "personalCoachId", coachId)
  )
  Belt.Option.forEach(filter.assignedCoachId, assignedCoachId =>
    Js.Dict.set(filterDict, "assignedCoachId", assignedCoachId)
  )

  switch filter.tab {
  | Some(tab) =>
    switch tab {
    | #Pending => Js.Dict.set(filterDict, "tab", "Pending")
    | #Reviewed => Js.Dict.set(filterDict, "tab", "Reviewed")
    }
  | None => ()
  }

  filter.includeInactive ? Js.Dict.set(filterDict, "includeInactive", "true") : ()

  open Webapi.Url
  URLSearchParams.makeWithDict(filterDict)->URLSearchParams.toString
}
