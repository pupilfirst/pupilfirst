type t = {
  sortDirection: [ | `Ascending | `Descending],
  sortCriterion: [ | `EvaluatedAt | `SubmittedAt],
};

let make = (~sortDirection, ~sortCriterion) => {
  sortDirection,
  sortCriterion,
};

let sortDirection = t => t.sortDirection;

let sortCriterion = t => t.sortCriterion;

let updateDirection = (sortDirection, t) => {...t, sortDirection};

let updateCriterion = (sortCriterion, t) => {...t, sortCriterion};
