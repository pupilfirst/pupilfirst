type sortDirection = [#Ascending | #Descending]
type sortCriterion = [#EvaluatedAt | #SubmittedAt]

type t = {
  sortDirection: sortDirection,
  sortCriterion: sortCriterion,
}

let make = (~sortDirection, ~sortCriterion) => {
  sortDirection: sortDirection,
  sortCriterion: sortCriterion,
}

let default = () => make(~sortCriterion=#SubmittedAt, ~sortDirection=#Ascending)

let sortDirection = t => t.sortDirection

let sortCriterion = t => t.sortCriterion

let updateDirection = (sortDirection, t) => {...t, sortDirection: sortDirection}

let updateCriterion = (sortCriterion, t) => {...t, sortCriterion: sortCriterion}
