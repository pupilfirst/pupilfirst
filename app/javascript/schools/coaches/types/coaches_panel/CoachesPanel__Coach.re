type t = {
  id: int,
  name: string,
  imageUrl: string,
  email: string,
};

let name = t => t.name;

let id = t => t.id;

let email = t => t.email;

let imageUrl = t => t.imageUrl;

let updateInfo = (name, coach) => {...coach, name};

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    id: json |> field("id", int),
    imageUrl: json |> field("imageUrl", string),
    email: json |> field("email", string),
  };

let encode = t =>
  Json.Encode.(
    object_([
      ("id", t.id |> int),
      ("name", t.name |> string),
      ("image_url", t.imageUrl |> string),
      ("email", t.email |> string),
    ])
  );