type t = {
  name: string,
  email: string,
  tags: list(string),
};

let name = t => t.name;

let email = t => t.email;

let tags = t => t.tags;

let encode = t =>
  Json.Encode.(
    object_([
      ("name", t.name |> string),
      ("email", t.email |> string),
      ("tags", t.tags |> list(string)),
    ])
  );

let create = (name, email, tags) => {name, email, tags};