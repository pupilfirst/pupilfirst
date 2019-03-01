type t = {
  name: string,
  email: string,
};

let name = t => t.name;

let email = t => t.email;

let encode = t => Json.Encode.(object_([("name", t.name |> string), ("email", t.email |> string)]));

let create = (name, email) => {name, email};
