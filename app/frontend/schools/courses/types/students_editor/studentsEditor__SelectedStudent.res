type t = {
  name: string,
  id: string,
  teamId: string,
  avatarUrl: option<string>,
  levelId: string,
  teamSize: int,
}

let id = t => t.id

let avatarUrl = t => t.avatarUrl

let name = t => t.name

let selectedAcrossTeams = selectedStudents =>
  Array.length(ArrayUtils.distinct(Array.map(s => s.teamId, selectedStudents))) > 1

let partOfTeamSelected = selectedStudents => {
  let selectedTeamSize = Array.length(selectedStudents)

  Array.length(Js.Array.filter(s => s.teamSize > selectedTeamSize, selectedStudents)) ==
    selectedTeamSize
}

let selectedWithinLevel = selectedStudents =>
  Array.length(
    ArrayUtils.sortUniq(String.compare, Array.map(s => s.levelId, selectedStudents)),
  ) == 1

let isGroupable = selectedStudents =>
  if Array.length(selectedStudents) > 1 {
    (selectedWithinLevel(selectedStudents) && selectedAcrossTeams(selectedStudents)) ||
      partOfTeamSelected(selectedStudents)
  } else {
    false
  }

let isMoveOutable = selectedStudents =>
  Array.length(selectedStudents) == 1 && Array.map(s => s.teamSize, selectedStudents) != [1]

let make = (~name, ~id, ~teamId, ~avatarUrl, ~levelId, ~teamSize) => {
  name,
  id,
  teamId,
  avatarUrl,
  levelId,
  teamSize,
}
