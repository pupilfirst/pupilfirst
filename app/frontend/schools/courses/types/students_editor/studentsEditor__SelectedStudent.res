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
  selectedStudents->Array.map(s => s.teamId)->ArrayUtils.distinct->Array.length > 1

let partOfTeamSelected = selectedStudents => {
  let selectedTeamSize = Array.length(selectedStudents)

  selectedStudents->Array.filter(s => s.teamSize > selectedTeamSize)->Array.length ==
    selectedTeamSize
}

let selectedWithinLevel = selectedStudents =>
  Array.length(
    ArrayUtils.sortUniq(String.compare, selectedStudents->Array.map(s => s.levelId)),
  ) == 1

let isGroupable = selectedStudents =>
  if Array.length(selectedStudents) > 1 {
    (selectedWithinLevel(selectedStudents) && selectedAcrossTeams(selectedStudents)) ||
      partOfTeamSelected(selectedStudents)
  } else {
    false
  }

let isMoveOutable = selectedStudents =>
  Array.length(selectedStudents) == 1 && selectedStudents->Array.map(s => s.teamSize) != [1]

let make = (~name, ~id, ~teamId, ~avatarUrl, ~levelId, ~teamSize) => {
  name,
  id,
  teamId,
  avatarUrl,
  levelId,
  teamSize,
}
