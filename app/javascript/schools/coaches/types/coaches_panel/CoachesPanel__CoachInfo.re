type t = {
  name: string,
  email: string,
  title: string,
};

let name = t => t.name;

let email = t => t.email;

let title = t => t.title;

let encode = t =>
  Json.Encode.(
    object_([
      ("name", t.name |> string),
      ("email", t.email |> string),
      ("title", t.title |> string),
    ])
  );

let create = (name, email, title) => {name, email, title};