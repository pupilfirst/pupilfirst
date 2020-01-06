type t = {
  name: string,
  id: string,
  teamId: string,
  avatarUrl: option(string),
  levelId: string,
  studentsCount: int,
};

let id = t => t.id;

let avatarUrl = t => t.avatarUrl;

let name = t => t.name;

let selectedAcrossTeams = selectedStudents =>
  selectedStudents
  |> Array.map(s => s.teamId)
  |> ArrayUtils.distinct
  |> Array.length > 1;

let partOfTeamSelected = selectedStudents => {
  let selectedStudentsCount = selectedStudents |> Array.length;

  selectedStudents
  |> Array.map(s => s.studentsCount <= selectedStudentsCount)
  |> Js.Array.filter(t => !t)
  |> Array.length == selectedStudentsCount;
};

let selectedWithinLevel = selectedStudents => {
  selectedStudents
  |> Array.map(s => s.levelId)
  |> ArrayUtils.sort_uniq(String.compare)
  |> Array.length == 1;
};

let isGroupable = selectedStudents =>
  if (selectedStudents |> Array.length > 1) {
    selectedWithinLevel(selectedStudents)
    && selectedAcrossTeams(selectedStudents)
    || partOfTeamSelected(selectedStudents);
  } else {
    false;
  };

let isMoveOutable = selectedStudents => {
  selectedStudents |> Array.map(s => s.studentsCount) == [|1|];
};

let make = (~name, ~id, ~teamId, ~avatarUrl, ~levelId, ~studentsCount) => {
  name,
  id,
  teamId,
  avatarUrl,
  levelId,
  studentsCount,
};
