type selectedTab = [#Reviewed | #Pending]
type sortDirection = [#Ascending | #Descending]
type sortCriterion = [#EvaluatedAt | #SubmittedAt]

type t = {
  nameOrEmail: option<string>,
  levelId: option<string>,
  coachId: option<string>,
  targetId: option<string>,
  sortCriterion: sortCriterion,
  sortDirection: sortDirection,
  tab: option<selectedTab>,
}

let nameOrEmail = t => t.nameOrEmail
let levelId = t => t.levelId
let coachId = t => t.coachId
let targetId = t => t.targetId
let sortCriterion = t => t.sortCriterion
let sortDirection = t => t.sortDirection
let tab = t => t.tab

let makeFromQueryParams = search => {
  let params = Webapi.Url.URLSearchParams.make(search)

  open Webapi.Url.URLSearchParams
  {
    nameOrEmail: get("search", params),
    levelId: get("levelId", params),
    coachId: get("coachId", params),
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
  Belt.Option.forEach(filter.coachId, coachId => Js.Dict.set(filterDict, "coachId", coachId))

  switch filter.tab {
  | Some(tab) =>
    switch tab {
    | #Pending => Js.Dict.set(filterDict, "tab", "Pending")
    | #Reviewed => Js.Dict.set(filterDict, "tab", "Reviewed")
    }
  | None => ()
  }

  open Webapi.Url
  URLSearchParams.makeWithDict(filterDict)->URLSearchParams.toString
}
