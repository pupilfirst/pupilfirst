type t = {
  name: string,
  tags: array(string),
  students: array(StudentsEditor__StudentInfo.t),
};

let name = t => t.name;

let tags = t => t.tags;

let encode = t =>
  Json.Encode.(
    object_([
      ("name", t.name |> string),
      ("tags", t.tags |> array(string)),
      ("students", t.students |> array(StudentsEditor__StudentInfo.encode)),
    ])
  );

let make = (~name, ~tags, ~students) => {name, tags, students};
