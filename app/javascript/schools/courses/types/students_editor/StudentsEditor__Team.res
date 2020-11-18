type t = {
  id: string,
  name: string,
  coachIds: array<string>,
  levelId: string,
  accessEndsAt: option<Js.Date.t>,
  tags: array<string>,
  students: array<StudentsEditor__Student.t>,
}

let id = t => t.id

let name = t => t.name

let coachIds = t => t.coachIds

let accessEndsAt = t => t.accessEndsAt

let levelId = t => t.levelId

let tags = t => t.tags

let students = t => t.students

let isSingleStudent = t => t.students |> Array.length == 1

let make = (~id, ~name, ~tags, ~students, ~coachIds, ~levelId, ~accessEndsAt) => {
  id: id,
  name: name,
  tags: tags,
  students: students,
  coachIds: coachIds,
  levelId: levelId,
  accessEndsAt: accessEndsAt,
}

let makeFromJS = teamDetails => teamDetails |> Js.Array.map(team =>
    switch team {
    | Some(team) =>
      let students =
        team["students"] |> Array.map(studentDetails =>
          StudentsEditor__Student.makeFromJS(studentDetails)
        )
      let coachIds = team["coachIds"] |> Array.map(cids => cids)
      list{
        make(
          ~id=team["id"],
          ~name=team["name"],
          ~tags=team["tags"],
          ~levelId=team["levelId"],
          ~students,
          ~coachIds,
          ~accessEndsAt=team["accessEndsAt"]->Belt.Option.map(DateFns.decodeISO),
        ),
      }
    | None => list{}
    }
  )

let update = (~name, ~tags, ~student, ~coachIds, ~accessEndsAt, ~team) => {
  let students =
    team.students |> Array.map(s =>
      s |> StudentsEditor__Student.id == (student |> StudentsEditor__Student.id) ? student : s
    )

  {
    ...team,
    name: name,
    tags: tags,
    coachIds: coachIds,
    accessEndsAt: accessEndsAt,
    students: students,
  }
}

let replaceTeam = (team, teams) => teams |> Array.map(t => t.id == team.id ? team : t)

let unsafeFind = (teams, componentName, teamId) =>
  teams |> ArrayUtils.unsafeFind(
    team => team.id == teamId,
    "Unable to find team with id: " ++ (teamId ++ ("in StudentdEditor__" ++ componentName)),
  )

let active = t => t.accessEndsAt->Belt.Option.mapWithDefault(true, DateFns.isFuture)

let updateStudent = (t, student) => {
  ...t,
  students: Js.Array.map(
    s => StudentsEditor__Student.id(student) == StudentsEditor__Student.id(s) ? student : s,
    t.students,
  ),
}
