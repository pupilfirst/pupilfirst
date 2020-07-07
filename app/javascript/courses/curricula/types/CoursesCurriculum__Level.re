type t = {
  id: string,
  name: string,
  number: int,
  unlockAt: option(Js.Date.t),
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    number: json |> field("number", int),
    unlockAt: json |> optional(field("unlockAt", DateFns.decodeISO)),
  };

let id = t => t.id;
let name = t => t.name;
let number = t => t.number;
let unlockAt = t => t.unlockAt;

let isUnlocked = t =>
  switch (t.unlockAt) {
  | Some(date) => DateFns.isPast(date)
  | None => true
  };

let isLocked = t => !(t |> isUnlocked);

let sort = levels => levels |> List.sort((x, y) => x.number - y.number);

let first = levels =>
  switch (levels |> sort) {
  | [] =>
    Rollbar.error("Failed to find the first level from a course's levels.");
    raise(Not_found);
  | [firstLevel, ..._rest] => firstLevel
  };

let unlockDateString = t =>
  switch (t.unlockAt) {
  | None =>
    Rollbar.error(
      "unlockDateString was called for a CoursesCurriculum__Level without unlockAt",
    );
    "";
  | Some(unlockAt) => DateFns.format(unlockAt, "MMM d")
  };

let findByLevelNumber = (levels, levelNumber) =>
  levels |> List.find_opt(l => l.number == levelNumber);

let next = (levels, t) => {
  t.number + 1 |> findByLevelNumber(levels);
};

let previous = (levels, t) => {
  let previousLevelNumber = t.number - 1;

  if (previousLevelNumber == 0) {
    None;
  } else {
    previousLevelNumber |> findByLevelNumber(levels);
  };
};
