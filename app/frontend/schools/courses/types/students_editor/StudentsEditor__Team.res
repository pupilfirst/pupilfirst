type t = {
  id: string,
  name: string,
  coachIds: array<string>,
  levelId: string,
  teamTags: array<string>,
  students: array<StudentsEditor__Student.t>,
}

let id = t => t.id

let name = t => t.name

let coachIds = t => t.coachIds

let levelId = t => t.levelId

let tags = t => t.teamTags

let students = t => t.students

let isSingleStudent = t => t.students |> Array.length == 1

let make = (~id, ~name, ~teamTags, ~students, ~coachIds, ~levelId) => {
  id: id,
  name: name,
  teamTags: teamTags,
  students: students,
  coachIds: coachIds,
  levelId: levelId,
}

let makeFromJS = teamDetails => Js.Array.map(team => {
    let students = Js.Array.map(
      studentDetails => StudentsEditor__Student.makeFromJS(studentDetails),
      team["students"],
    )
    let coachIds = Js.Array.map(cids => cids, team["coachIds"])

    make(
      ~id=team["id"],
      ~name=team["name"],
      ~teamTags=team["teamTags"],
      ~levelId=team["levelId"],
      ~students,
      ~coachIds,
    )
  }, teamDetails)

let update = (~name, ~teamTags, ~student, ~coachIds, ~team) => {
  let students =
    team.students |> Array.map(s =>
      s |> StudentsEditor__Student.id == (student |> StudentsEditor__Student.id) ? student : s
    )
  {
    ...team,
    name: name,
    teamTags: teamTags,
    coachIds: coachIds,
    students: students,
  }
}

let replaceTeam = (team, teams) => teams |> Array.map(t => t.id == team.id ? team : t)

let unsafeFind = (teams, componentName, teamId) =>
  teams |> ArrayUtils.unsafeFind(
    team => team.id == teamId,
    "Unable to find team with id: " ++ (teamId ++ ("in StudentdEditor__" ++ componentName)),
  )

let updateStudent = (t, student) => {
  ...t,
  students: Js.Array.map(
    s => StudentsEditor__Student.id(student) == StudentsEditor__Student.id(s) ? student : s,
    t.students,
  ),
}
