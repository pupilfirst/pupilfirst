type selectedTab = [#Reviewed | #Pending]
type sortDirection = [#Ascending | #Descending]
type sortCriterion = [#EvaluatedAt | #SubmittedAt]

type t = {
  nameOrEmail: option<string>,
  personalCoachId: option<string>,
  assignedCoachId: option<string>,
  reviewingCoachId: option<string>,
  targetId: option<string>,
  sortCriterion: sortCriterion,
  sortDirection: option<sortDirection>,
  tab: option<selectedTab>,
  includeInactive: bool,
}

let nameOrEmail = t => t.nameOrEmail
let targetId = t => t.targetId
let sortCriterion = t => t.sortCriterion
let sortDirection = t => t.sortDirection
let tab = t => t.tab
let includeInactive = t => t.includeInactive
let assignedCoachId = t => t.assignedCoachId
let personalCoachId = t => t.personalCoachId
let reviewingCoachId = t => t.reviewingCoachId

let defaultDirection = t => {
  switch t.sortDirection {
  | Some(direction) => direction
  | None =>
    switch t.tab {
    | Some(tab) if tab == #Pending => #Ascending
    | _ => #Descending
    }
  }
}

let makeFromQueryParams = search => {
  let params = Webapi.Url.URLSearchParams.make(search)

  open Webapi.Url.URLSearchParams
  {
    nameOrEmail: get(params, "search"),
    personalCoachId: get(params, "personalCoachId"),
    assignedCoachId: get(params, "assignedCoachId"),
    reviewingCoachId: get(params, "reviewingCoachId"),
    targetId: get(params, "targetId"),
    tab: switch get(params, "tab") {
    | Some(t) if t == "Pending" => Some(#Pending)
    | Some(t) if t == "Reviewed" => Some(#Reviewed)
    | _ => None
    },
    sortCriterion: switch get(params, "sortCriterion") {
    | Some(criterion) if criterion == "EvaluatedAt" => #EvaluatedAt
    | Some(criterion) if criterion == "SubmittedAt" => #SubmittedAt
    | _ => #SubmittedAt
    },
    sortDirection: switch get(params, "sortDirection") {
    | Some(direction) if direction == "Descending" => Some(#Descending)
    | Some(direction) if direction == "Ascending" => Some(#Ascending)
    | _ => None
    },
    includeInactive: switch get(params, "includeInactive") {
    | Some(t) if t == "true" => true
    | _ => false
    },
  }
}

let toQueryString = filter => {
  let sortCriterion = switch filter.sortCriterion {
  | #EvaluatedAt => "EvaluatedAt"
  | #SubmittedAt => "SubmittedAt"
  }

  let filterDict = Js.Dict.fromArray([("sortCriterion", sortCriterion)])

  switch filter.sortDirection {
  | Some(direction) =>
    Js.Dict.set(
      filterDict,
      "sortDirection",
      switch direction {
      | #Descending => "Descending"
      | #Ascending => "Ascending"
      },
    )
  | _ => ()
  }
  Belt.Option.forEach(filter.nameOrEmail, search => Js.Dict.set(filterDict, "search", search))
  Belt.Option.forEach(filter.targetId, targetId => Js.Dict.set(filterDict, "targetId", targetId))

  Belt.Option.forEach(filter.personalCoachId, coachId =>
    Js.Dict.set(filterDict, "personalCoachId", coachId)
  )

  if filter.tab != Some(#Reviewed) {
    Belt.Option.forEach(filter.assignedCoachId, assignedCoachId =>
      Js.Dict.set(filterDict, "assignedCoachId", assignedCoachId)
    )
  }

  if filter.tab != Some(#Pending) {
    Belt.Option.forEach(filter.reviewingCoachId, reviewingCoachId =>
      Js.Dict.set(filterDict, "reviewingCoachId", reviewingCoachId)
    )
  }

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
