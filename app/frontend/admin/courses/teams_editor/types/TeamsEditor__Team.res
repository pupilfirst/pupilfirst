type t = {
  id: string,
  name: string,
  students: array<UserProxy.t>,
  cohort: Cohort.t,
}

let id = t => t.id
let name = t => t.name
let students = t => t.students
let cohort = t => t.cohort

let make = (~id, ~name, ~students, ~cohort) => {id, name, students, cohort}
