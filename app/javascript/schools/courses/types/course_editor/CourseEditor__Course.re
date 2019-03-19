type t = {
  id: int,
  name: string,
  endsAt: option(string),
  maxGrade: int,
  passGrade: int,
};

let name = t => t.name;

let id = t => t.id;

let endsAt = t => t.endsAt;

let maxGrade = t => t.maxGrade;

let passGrade = t => t.passGrade;

let sort = courses => courses |> List.sort((x, y) => x.id - y.id);

let create = (id, name, endsAt, maxGrade, passGrade) => {
  id,
  name,
  endsAt,
  maxGrade,
  passGrade,
};