type t = {
  name: string,
  email: string,
  tags: array(string),
  title: string,
  affiliation: string,
};

let name = t => t.name;

let email = t => t.email;

let tags = t => t.tags;

let title = t => t.title;

let affiliation = t => t.affiliation;

let encode = t =>
  Json.Encode.(
    object_([
      ("name", t.name |> string),
      ("email", t.email |> string),
      ("title", t.title |> string),
      ("affiliation", t.affiliation |> string),
      ("tags", t.tags |> array(string)),
    ])
  );

let make = (name, email, title, affiliation, tags) => {
  name,
  email,
  title,
  affiliation,
  tags,
};
