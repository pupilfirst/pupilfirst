type t = {
  sortDirection: [#Ascending | #Descending],
  sortCriterion: [#EvaluatedAt | #SubmittedAt],
}

let make = (~sortDirection, ~sortCriterion) => {
  sortDirection: sortDirection,
  sortCriterion: sortCriterion,
}

let sortDirection = t => t.sortDirection

let sortCriterion = t => t.sortCriterion

let updateDirection = (sortDirection, t) => {...t, sortDirection: sortDirection}

let updateCriterion = (sortCriterion, t) => {...t, sortCriterion: sortCriterion}
